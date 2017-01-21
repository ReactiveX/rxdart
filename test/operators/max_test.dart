import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0]);

Stream<Map<String, int>> _getErroneousStream() {
  StreamController<Map<String, int>> controller = new StreamController();

  controller.add(const <String, int>{'value': 10});
  controller.add(const <String, int>{'value': 12});
  new Timer(new Duration(milliseconds: 20), () {
    controller.addError(new Exception());
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.max', () async {
    const List<int> expectedOutput = const <int>[2, 3, 5, 9];
    int count = 0;

    observable(_getStream()).max().listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.max.withCompare', () async {
    const List<int> expectedOutput = const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0];
    int count = 0;

    observable(_getStream())
        .max((int a, int b) => 1)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.min.withCompare.withoutComparable', () async {
    const List<Map<String, int>> expectedOutput = const <Map<String, int>>[
      const <String, int>{'value': 10},
      const <String, int>{'value': 12}
    ];
    int count = 0;

    observable(_getErroneousStream())
        .max((Map<String, int> a, Map<String, int> b) =>
            a['value'].compareTo(b['value']))
        .listen(
            expectAsync1((Map<String, int> result) {
              expect(expectedOutput[count++], result);
            }, count: expectedOutput.length), onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.max.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream()).max();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.max.error.shouldThrow', () async {
    Stream<num> observableWithError = observable(getErroneousStream()).max();

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
