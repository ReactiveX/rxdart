import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [0, 1, 2, 3, 4]);

void main() {
  test('rx.Observable.interval', () async {
    const expectedOutput = [0, 1, 2, 3, 4];
    var count = 0, lastInterval = -1;
    final stopwatch = new Stopwatch()..start();

    new Observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .listen(
            expectAsync1((result) {
              expect(expectedOutput[count++], result);

              if (lastInterval != -1)
                expect(stopwatch.elapsedMilliseconds - lastInterval >= 1, true);

              lastInterval = stopwatch.elapsedMilliseconds;
            }, count: expectedOutput.length),
            onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.reusable', () async {
    final transformer =
        new IntervalStreamTransformer<int>(const Duration(milliseconds: 1));
    const expectedOutput = [0, 1, 2, 3, 4];
    var countA = 0, countB = 0;
    final stopwatch = new Stopwatch()..start();

    new Observable(_getStream()).transform(transformer).listen(
        expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length),
        onDone: stopwatch.stop);

    new Observable(_getStream()).transform(transformer).listen(
        expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length),
        onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.asBroadcastStream', () async {
    final stream = new Observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.interval.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception()))
            .interval(const Duration(milliseconds: 20));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.interval.error.shouldThrowB', () async {
    runZoned(() {
      final observableWithError =
          new Observable.just(1).interval(const Duration(milliseconds: 20));

      observableWithError.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (self, parent, zone, duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });
}
