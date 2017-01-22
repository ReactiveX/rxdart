import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 4000), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.tap', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    int count = 0;

    observable(_getStream())
        .tap((int value) => expect(expectedOutput[count++], value))
        .listen((_) {});
  });

  test('rx.Observable.tap.asBroadcastStream', () async {
    Stream<int> stream =
        observable(_getStream().asBroadcastStream()).tap((_) {});

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.tap.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).tap((_) {});

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
