library rx.test.operators.replay;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream _getStream() {
  StreamController<int> controller = new StreamController<int>();

  controller.add(1);
  controller.add(2);
  controller.add(3);
  controller.add(4);

  new Timer(const Duration(milliseconds: 400), () {
    controller.add(5);
    controller.close();
  });

  return controller.stream.asBroadcastStream();
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
  test('rx.Observable.replay', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4, 5];
    rx.Observable<int> stream = rx.observable(_getStream()).replay();
    int count = 0, count2 = 0;

    stream
      .listen((int result) {
        expect(expectedOutput[count++], result);
      });

    new Timer(const Duration(milliseconds: 200), () {
      stream
        .listen((int result) {
          expect(expectedOutput[count2++], result);
        });
    });

  });

  test('rx.Observable.replay.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .replay(4);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.replay.error.shouldThrow', () async {
    Stream<int> observableWithError = rx.observable(_getErroneousStream())
        .replay(4);

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}