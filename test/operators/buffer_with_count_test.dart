import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

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
  test('rx.Observable.bufferWithCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[const <int>[1, 2], const <int>[3, 4]];
    int count = 0;

    Stream<List<int>> observable = rx.observable(_getStream()).bufferWithCount(2);

    observable.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferWithCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[const <int>[1, 2], const <int>[2, 3], const <int>[3, 4], const <int>[4]];
    int count = 0;

    Stream<List<int>> observable = rx.observable(_getStream()).bufferWithCount(2, 1);

    observable.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1) expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.bufferWithCount.asBroadcastStream', () async {
    Stream<List<int>> observable = rx.observable(_getStream().asBroadcastStream())
      .bufferWithCount(2);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.bufferWithCount.error.shouldThrow', () async {
    Stream<List<num>> observableWithError = rx.observable(getErroneousStream())
      .bufferWithCount(2);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
