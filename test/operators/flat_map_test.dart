import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
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

Stream<num> _getOtherStream(num value) {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(value + 1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(value + 2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(value + 3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(value + 4);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.flatMap', () async {
    const List<int> expectedOutput = const <int>[
      2,
      3,
      3,
      4,
      4,
      4,
      5,
      5,
      5,
      5,
      6,
      6,
      6,
      7,
      7,
      8
    ];
    int count = 0;

    observable(_getStream())
        .flatMap(_getOtherStream)
        .listen(expectAsync1((num result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.asBroadcastStream', () async {
    Stream<num> stream =
        observable(_getStream().asBroadcastStream()).flatMap(_getOtherStream);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.flatMap.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).flatMap(_getOtherStream);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
