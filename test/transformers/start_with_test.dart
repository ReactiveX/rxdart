import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [1, 2, 3, 4]);

void main() {
  test('rx.Observable.startWith', () async {
    const expectedOutput = [5, 1, 2, 3, 4];
    var count = 0;

    new Observable(_getStream()).startWith(5).listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.startWith.reusable', () async {
    final transformer = new StartWithStreamTransformer<int>(5);
    const expectedOutput = [5, 1, 2, 3, 4];
    var countA = 0, countB = 0;

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.startWith.asBroadcastStream', () async {
    final stream =
        new Observable(_getStream().asBroadcastStream()).startWith(5);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.startWith.error.shouldThrow', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception())).startWith(5);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.startWith.pause.resume', () async {
    const expectedOutput = [5, 1, 2, 3, 4];
    var count = 0;

    StreamSubscription<int> subscription;
    subscription =
        new Observable(_getStream()).startWith(5).listen(expectAsync1((result) {
              expect(expectedOutput[count++], result);

              if (count == expectedOutput.length) {
                subscription.cancel();
              }
            }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
