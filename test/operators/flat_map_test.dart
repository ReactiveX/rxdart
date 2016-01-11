library rx.test.operators.flat_map;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rx.dart' as rx;

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

Stream _getOtherStream(num value) => new Stream<String>.fromIterable(['${value - 1}', '${value + 1}']);

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
  test('rx.Observable.flatMap', () async {
    const List<String> expectedOutput = const <String>['0', '2', '1', '3', '2', '4', '3', '5'];
    int count = 0;

    rx.observable(_getStream())
        .flatMap(_getOtherStream)
        .listen(expectAsync((String result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .flatMap(_getOtherStream);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.flatMap.error.shouldThrow', () async {
    Stream<int> observableWithError = rx.observable(_getErroneousStream())
        .flatMap(_getOtherStream);

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}