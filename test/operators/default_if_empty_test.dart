import '../test_utils.dart';
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

void main() {
  test('rx.Observable.defaultIfEmpty.whenEmpty', () async {
    rx.observable(new Stream<bool>.empty())
        .defaultIfEmpty(true)
        .listen(expectAsync1((bool result) {
      expect(result, true);
    }, count: 1));
  });

  test('rx.Observable.defaultIfEmpty.whenNotEmpty', () async {
    rx.observable(new Stream<bool>.fromIterable(const <bool>[false, false, false]))
        .defaultIfEmpty(true)
        .listen(expectAsync1((bool result) {
      expect(result, false);
    }, count: 3));
  });

  test('rx.Observable.defaultIfEmpty.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .defaultIfEmpty(-1);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.defaultIfEmpty.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(getErroneousStream())
        .defaultIfEmpty(-1);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
