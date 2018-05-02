import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4]);

void main() {
  test('rx.Observable.interval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4];
    int count = 0, lastInterval = -1;
    Stopwatch stopwatch = new Stopwatch()..start();

    new Observable<int>(_getStream())
        .interval(const Duration(milliseconds: 1))
        .listen(
            expectAsync1((int result) {
              expect(expectedOutput[count++], result);

              if (lastInterval != -1)
                expect(stopwatch.elapsedMilliseconds - lastInterval >= 1, true);

              lastInterval = stopwatch.elapsedMilliseconds;
            }, count: expectedOutput.length),
            onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.reusable', () async {
    final IntervalStreamTransformer<int> transformer =
        new IntervalStreamTransformer<int>(const Duration(milliseconds: 1));
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4];
    int countA = 0, countB = 0;
    Stopwatch stopwatch = new Stopwatch()..start();

    new Observable<int>(_getStream()).transform(transformer).listen(
        expectAsync1((int result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length),
        onDone: stopwatch.stop);

    new Observable<int>(_getStream()).transform(transformer).listen(
        expectAsync1((int result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length),
        onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.interval.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .interval(const Duration(milliseconds: 20));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.interval.error.shouldThrowB', () async {
    runZoned(() {
      Stream<num> observableWithError = new Observable<num>.just(1)
          .interval(const Duration(milliseconds: 20));

      observableWithError.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (Zone self, ZoneDelegate parent, Zone zone,
                    Duration duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });
}
