library rx.test.operators.window_with_count;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream _getStream() {
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

Stream _getErroneousStream() {
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
  test('rx.Observable.windowWithCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[const [1, 2], const [3, 4]];
    int count = 0;

    Stream<Stream<int>> observable = rx.observable(_getStream()).windowWithCount(2);

    observable.listen(expectAsync((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 2));
  });

  test('rx.Observable.windowWithCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[const [1, 2], const [2, 3], const [3, 4], const [4]];
    int count = 0;

    Stream<Stream<int>> observable = rx.observable(_getStream()).windowWithCount(2, 1);

    observable.listen(expectAsync((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 4));
  });

  test('rx.Observable.windowWithCount.asBroadcastStream', () async {
    Stream<Stream<int>> observable = rx.observable(_getStream().asBroadcastStream())
        .windowWithCount(2);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.windowWithCount.error.shouldThrow', () async {
    Stream<Stream<int>> observableWithError = rx.observable(_getErroneousStream())
        .windowWithCount(2);

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}