library rx.test.operators.time_interval;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

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
  test('rx.Observable.timeInterval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    int count = 0;

    rx.observable(_getStream())
        .interval(const Duration(milliseconds: 20))
        .timeInterval()
        .listen(expectAsync((rx.TimeInterval<int> result) {
          expect(expectedOutput[count++], result.value);

          expect(result.interval >= 20000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.asBroadcastStream', () async {
    Stream<rx.TimeInterval<int>> observable = rx.observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20))
        .timeInterval();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.timeInterval.error.shouldThrow', () async {
    Stream<rx.TimeInterval<num>> observableWithError = rx.observable(_getErroneousStream())
        .interval(const Duration(milliseconds: 20))
        .timeInterval();

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}