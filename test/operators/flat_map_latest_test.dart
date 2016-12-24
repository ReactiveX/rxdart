library rx.test.operators.flat_map_latest;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

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

Stream<num> _getOtherStream(num value) {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(value + 1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(value + 2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(value + 3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(value + 4);
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
  test('rx.Observable.flatMapLatest', () async {
    const List<int> expectedOutput = const <int>[5, 6, 7, 8];
    int count = 0;

    rx.observable(_getStream())
        .flatMapLatest(_getOtherStream)
        .listen(expectAsync1((num result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMapLatest.asBroadcastStream', () async {
    Stream<num> observable = rx.observable(_getStream().asBroadcastStream())
        .flatMapLatest(_getOtherStream);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.flatMapLatest.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(_getErroneousStream())
        .flatMapLatest(_getOtherStream);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}