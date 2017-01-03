import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.fromIterable(const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0]);

Stream<Map<String, int>> _getErroneousStream() => new Stream<Map<String, int>>.fromIterable(const <Map<String, int>>[const <String, int>{'value': 10}, const <String, int>{'value': 12}, const <String, int>{'value': 8}]);

void main() {
  test('rx.Observable.max', () async {
    const List<int> expectedOutput = const <int>[2, 3, 5, 9];
    int count = 0;

    rx.observable(_getStream())
        .max()
        .listen(expectAsync1((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.max.withCompare', () async {
    const List<int> expectedOutput = const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0];
    int count = 0;

    rx.observable(_getStream())
        .max((int a, int b) => 1)
        .listen(expectAsync1((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.min.withCompare.withoutComparable', () async {
    const List<Map<String, int>> expectedOutput = const <Map<String, int>>[const <String, int>{'value': 10}, const <String, int>{'value': 12}];
    int count = 0;

    rx.observable(_getErroneousStream())
        .max((Map<String, int> a, Map<String, int> b) => a['value'].compareTo(b['value']))
        .listen(expectAsync1((Map<String, int> result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.max.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .max();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.max.error.shouldThrow', () async {
    Stream<Map<String, int>> observableWithError = rx.observable(_getErroneousStream())
        .max();

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}