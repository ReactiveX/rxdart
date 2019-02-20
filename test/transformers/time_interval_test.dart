import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => Stream<int>.fromIterable(<int>[0, 1, 2]);

void main() {
  test('rx.Observable.timeInterval', () async {
    const expectedOutput = [0, 1, 2];
    var count = 0;

    Observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval()
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result.value);

          expect(
              result.interval.inMicroseconds >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.reusable', () async {
    final transformer = TimeIntervalStreamTransformer<int>();
    const expectedOutput = [0, 1, 2];
    var countA = 0, countB = 0;

    Observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result.value);

          expect(
              result.interval.inMicroseconds >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));

    Observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result.value);

          expect(
              result.interval.inMicroseconds >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.timeInterval.error.shouldThrow', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .interval(const Duration(milliseconds: 1))
        .timeInterval();

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.timeInterval.pause.resume', () async {
    StreamSubscription<TimeInterval<int>> subscription;
    const expectedOutput = [0, 1, 2];
    var count = 0;

    subscription = Observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval()
        .listen(expectAsync1((result) {
          expect(result.value, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
