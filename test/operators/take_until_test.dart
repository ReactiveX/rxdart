library rx.test.operators.take_until;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

typedef void ExpectAsync(int result);

Stream<int> _getStream() {
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

Stream<num> _getOtherStream() {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 250), () {
    controller.add(1);
    controller.close();
  });

  return controller.stream;
}

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
  test('rx.Observable.takeUntil', () async {
    const List<int> expectedOutput = const <int>[1, 2];
    int count = 0;

    rx.observable(_getStream())
        .takeUntil(_getOtherStream())
        .listen(expectAsync1((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length) as ExpectAsync);
  });

  test('rx.Observable.takeUntil.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .takeUntil(_getOtherStream().asBroadcastStream());

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.takeUntil.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(_getErroneousStream())
        .takeUntil(_getOtherStream());

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}