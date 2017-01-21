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

void main() {
  test('rx.Observable.scan', () async {
    const List<int> expectedOutput = const <int>[1, 3, 6, 10];
    int count = 0;

    observable(_getStream())
        .scan((int acc, int value, int index) =>
            ((acc == null) ? 0 : acc) + value)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.scan.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream()).scan(
        (int acc, int value, int index) => ((acc == null) ? 0 : acc) + value,
        0);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.scan.error.shouldThrow', () async {
    Stream<int> observableWithError =
        observable(getErroneousStream()).scan((num acc, num value, int index) {
      throw new Error();
    });

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
