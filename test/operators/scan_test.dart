library rx.test.operators.scan;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

typedef void ExpectAsync(int result);

Stream _getStream() {
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream _getErroneousStream() {
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
  test('rx.Observable.scan', () async {
    const List<int> expectedOutput = const <int>[1, 3, 6, 10];
    int count = 0;

    rx.observable(_getStream())
        .scan((int acc, int value, int index) => ((acc == null) ? 0 : acc) + value)
        .listen(expectAsync((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length) as ExpectAsync);
  });

  test('rx.Observable.scan.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .scan((int acc, int value, int index) => ((acc == null) ? 0 : acc) + value, 0);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.scan.error.shouldThrow', () async {
    Stream<int> observableWithError = rx.observable(_getErroneousStream())
      .scan((num acc, num value, int index) {
        throw new Error();
      });

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}