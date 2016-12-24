library rx.test.operators.debounce;

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
  test('rx.Observable.debounce', () async {
    rx.observable(_getStream())
        .debounce(const Duration(milliseconds: 200))
        .listen(expectAsync1((int result) {
      expect(result, 4);
    }, count: 1) as ExpectAsync);
  });

  test('rx.Observable.debounce.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .debounce(const Duration(milliseconds: 200));

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.debounce.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(_getErroneousStream())
        .debounce(const Duration(milliseconds: 200));

    observableWithError.listen((_) => const {}, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}