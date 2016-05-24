library rx.test.operators.tap;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream _getStream() {
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 4000), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 300), () => controller.add(2));
  new Timer(const Duration(milliseconds: 500), () => controller.add(3));
  new Timer(const Duration(milliseconds: 700), () {
    controller.add(100 / 0); // throw!!!
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.tap', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    int count = 0;

    rx.observable(_getStream())
        .tap((int value) => expect(expectedOutput[count++], value))
        .listen((_) {});
  });

  test('rx.Observable.tap.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .tap((_) {});

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.tap.error.shouldThrow', () async {
    Stream<int> observableWithError = rx.observable(_getErroneousStream())
        .tap((_) {});

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}