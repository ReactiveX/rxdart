import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

void main() {
  test('rx.Observable.startWith', () async {
    const List<int> expectedOutput = const <int>[5, 1, 2, 3, 4];
    int count = 0;

    new Observable<int>(_getStream())
        .startWith(5)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.startWith.reusable', () async {
    final StartWithStreamTransformer<int> transformer =
        new StartWithStreamTransformer<int>(5);
    const List<int> expectedOutput = const <int>[5, 1, 2, 3, 4];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.startWith.asBroadcastStream', () async {
    Stream<int> stream =
        new Observable<int>(_getStream().asBroadcastStream()).startWith(5);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.startWith.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception())).startWith(5);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.startWith.pause.resume', () async {
    const List<int> expectedOutput = const <int>[5, 1, 2, 3, 4];
    int count = 0;

    StreamSubscription<int> subscription;
    subscription = new Observable<int>(_getStream())
        .startWith(5)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
