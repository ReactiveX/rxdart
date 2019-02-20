import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => Stream.fromIterable(const [1, 2, 3, 4]);

void main() {
  test('rx.Observable.startWithMany', () async {
    const expectedOutput = [5, 6, 1, 2, 3, 4];
    var count = 0;

    Observable(_getStream())
        .startWithMany(const [5, 6]).listen(expectAsync1((result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.startWithMany.reusable', () async {
    final transformer = StartWithManyStreamTransformer<int>(const [5, 6]);
    const expectedOutput = [5, 6, 1, 2, 3, 4];
    var countA = 0, countB = 0;

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.startWithMany.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream())
        .startWithMany(const [5, 6]);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.startWithMany.error.shouldThrowA', () async {
    final observableWithError =
        Observable(ErrorStream<int>(Exception())).startWithMany(const [5, 6]);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.startWithMany.error.shouldThrowA', () {
    expect(() => Observable.just(1).startWithMany(null), throwsArgumentError);
  });

  test('rx.Observable.startWithMany.pause.resume', () async {
    const expectedOutput = [5, 6, 1, 2, 3, 4];
    var count = 0;

    StreamSubscription<int> subscription;
    subscription = Observable(_getStream())
        .startWithMany(const [5, 6]).listen(expectAsync1((result) {
      expect(expectedOutput[count++], result);

      if (count == expectedOutput.length) {
        subscription.cancel();
      }
    }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
