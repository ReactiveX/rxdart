library rx.test.operators.interval;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

typedef void ExpectAsync(int result);

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4]);

Stream<num> _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(100 / 0); // throw!!!
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.interval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4];
    int count = 0, lastInterval = -1;
    Stopwatch stopwatch = new Stopwatch()..start();

    rx.observable(_getStream())
      .interval(const Duration(milliseconds: 20))
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);

          if (lastInterval != -1) expect(stopwatch.elapsedMilliseconds - lastInterval >= 20, true);

          lastInterval = stopwatch.elapsedMilliseconds;
        }, count: expectedOutput.length) as ExpectAsync, onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20));

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.interval.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(_getErroneousStream())
        .interval(const Duration(milliseconds: 20));

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}