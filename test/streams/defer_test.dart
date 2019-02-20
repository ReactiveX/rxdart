import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.defer', () async {
    const value = 1;

    final observable = _getDeferStream();

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });

  test('rx.Observable.defer.multiple.listeners', () async {
    const value = 1;

    final observable = _getBroadcastDeferStream();

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });

  test('rx.Observable.defer.single.subscription', () async {
    final observable = _getDeferStream();

    try {
      observable.listen(null);
      observable.listen(null);
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });

  test('rx.Observable.defer.error.shouldThrow', () async {
    final observableWithError = Observable.defer(() => _getErroneousStream());

    observableWithError.listen(null,
        onError: expectAsync1((Exception e) {
          expect(e, isException);
        }, count: 1));
  });
}

Stream<int> _getDeferStream() => Observable.defer(() => Observable.just(1));

Stream<int> _getBroadcastDeferStream() =>
    Observable.defer(() => Observable.just(1)).asBroadcastStream();

Stream<int> _getErroneousStream() {
  final controller = StreamController<int>();

  controller.addError(Exception());
  controller.close();

  return controller.stream;
}
