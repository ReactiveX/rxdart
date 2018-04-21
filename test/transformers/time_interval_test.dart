import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2]);

void main() {
  test('rx.Observable.timeInterval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2];
    int count = 0;

    new Observable<int>(_getStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval()
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(expectedOutput[count++], result.value);

          expect(
              result.interval.inMicroseconds >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.reusable', () async {
    final TimeIntervalStreamTransformer<int> transformer =
        new TimeIntervalStreamTransformer<int>();
    const List<int> expectedOutput = const <int>[0, 1, 2];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream())
        .interval(const Duration(milliseconds: 1))
        .transform(transformer)
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(expectedOutput[countA++], result.value);

          expect(
              result.interval.inMicroseconds >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));

    new Observable<int>(_getStream())
        .interval(const Duration(milliseconds: 1))
        .transform(transformer)
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(expectedOutput[countB++], result.value);

          expect(
              result.interval.inMicroseconds >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.asBroadcastStream', () async {
    Stream<TimeInterval<int>> stream =
        new Observable<int>(_getStream().asBroadcastStream())
            .interval(const Duration(milliseconds: 1))
            .timeInterval();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.timeInterval.error.shouldThrow', () async {
    Stream<TimeInterval<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .interval(const Duration(milliseconds: 1))
            .timeInterval();

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.timeInterval.pause.resume', () async {
    StreamSubscription<TimeInterval<int>> subscription;
    const List<int> expectedOutput = const <int>[0, 1, 2];
    int count = 0;

    subscription = new Observable<int>(_getStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval()
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(result.value, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
