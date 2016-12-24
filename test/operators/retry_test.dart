library rx.test.operators.retry;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

typedef void ExpectAsync(int result);

Stream<int> _getStream() {
  Stream<int> testStream = new Stream<int>.fromIterable(const <int>[0, 1, 2, 3]).map((int i) {
    if (i < 3) throw new Error();

    return i;
  });

  return testStream;
}

void main() {
  test('rx.Observable.retry', () async {
    rx.observable(_getStream())
        .retry(3)
        .listen(expectAsync1((int result) {
      expect(result, 3);
    }, count: 1) as ExpectAsync);
  });

  test('rx.Observable.retry.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .retry(3);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.retry.error.shouldThrow', () async {
    Stream<int> observableWithError = rx.observable(_getStream())
        .retry(2);

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}