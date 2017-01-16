import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

void main() {
  test('rx.Observable.defer', () async {
    const int value = 1;

    Stream<int> observable = _getDeferStream();

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });

  test('rx.Observable.defer.multiple.listeners', () async {
    const int value = 1;

    Stream<int> observable = _getDeferStream();

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });

  test('rx.Observable.defer.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new rx.Observable<int>.defer(() => _getErroneousStream());

    observableWithError.listen(null,
        onError: expectAsync1((dynamic e) {
          expect(e, isException);
        }, count: 1));
  });
}

Stream<int> _getDeferStream() =>
    new rx.Observable<int>.defer(() => new rx.Observable<int>.just(1));

Stream<int> _getErroneousStream() {
  StreamController<int> controller = new StreamController<int>();

  controller.addError(new Exception());
  controller.close();

  return controller.stream;
}
