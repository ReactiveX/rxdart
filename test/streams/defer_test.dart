import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

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

    Stream<int> observable = _getBroadcastDeferStream();

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });

  test('rx.Observable.defer.single.subscription', () async {
    Stream<int> observable = _getDeferStream();

    try {
      observable.listen((_) {});
      observable.listen((_) {});
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });

  test('rx.Observable.defer.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new Observable<int>.defer(() => _getErroneousStream());

    observableWithError.listen(null,
        onError: expectAsync1((Exception e) {
          expect(e, isException);
        }, count: 1));
  });
}

Stream<int> _getDeferStream() =>
    new Observable<int>.defer(() => new Observable<int>.just(1));

Stream<int> _getBroadcastDeferStream() =>
    new Observable<int>.defer(() => new Observable<int>.just(1))
        .asBroadcastStream();

Stream<int> _getErroneousStream() {
  StreamController<int> controller = new StreamController<int>();

  controller.addError(new Exception());
  controller.close();

  return controller.stream;
}
