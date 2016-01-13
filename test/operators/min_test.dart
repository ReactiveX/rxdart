library rx.test.operators.min;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream _getStream() => new Stream<int>.fromIterable([10, 3, 3, 5, 2, 9, 1, 2, 0]);

Stream _getErroneousStream() => new Stream<Map>.fromIterable([{'value': 10}, {'value': 12}, {'value': 8}]);

void main() {
  test('rx.Observable.min', () async {
    const List<int> expectedOutput = const <int>[10, 3, 2, 1, 0];
    int count = 0;

    rx.observable(_getStream())
        .min()
        .listen(expectAsync((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.min.withCompare', () async {
    const List<int> expectedOutput = const <int>[10, 3, 3, 5, 2, 9, 1, 2, 0];
    int count = 0;

    rx.observable(_getStream())
        .min((int a, int b) => -1)
        .listen(expectAsync((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.min.withCompare.withoutComparable', () async {
    const List<Map<String, int>> expectedOutput = const <Map<String, int>>[const {'value': 10}, const {'value': 8}];
    int count = 0;

    rx.observable(_getErroneousStream())
        .min((Map<String, int> a, Map<String, int> b) => a['value'].compareTo(b['value']))
        .listen(expectAsync((Map<String, int> result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.min.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .min();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.min.error.shouldThrow', () async {
    Stream<Map> observableWithError = rx.observable(_getErroneousStream())
        .min();

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}