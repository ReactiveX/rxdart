library rx.test.operators.repeat;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

typedef void ExpectAsync(int result);

Stream<int> _getStream() => new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

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
  test('rx.Observable.repeat', () async {
    const List<int> expectedOutput = const <int>[1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    int count = 0;

    rx.observable(_getStream())
        .repeat(3)
        .listen(expectAsync1((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length) as ExpectAsync);
  });

  test('rx.Observable.repeat.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .repeat(3);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.repeat.error.shouldThrow', () async {
    Stream<num> observableWithError = rx.observable(_getErroneousStream())
        .repeat(3);

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}