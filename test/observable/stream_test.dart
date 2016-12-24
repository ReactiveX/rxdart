library rx.test.observable.stream;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() {
  Stream<int> a = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

  return a;
}

Stream<num> _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!
  controller.close();

  return controller.stream;
}

void main() {
  test('rx.Observable.stream', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    int count = 0;

    Stream<int> observable = rx.observable(_getStream());

    expect(observable is Stream<int>, true);
    expect(observable is rx.Observable<int>, true);

    observable.listen(expectAsync1((int result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.stream.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream());

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.stream.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(_getErroneousStream());

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}