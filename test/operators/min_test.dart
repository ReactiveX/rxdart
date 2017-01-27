import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[10, 3, 3, 5, 2, 9, 1, 2, 0]);

Stream<Map<String, int>> _getErroneousStream() {
  StreamController<Map<String, int>> controller =
      new StreamController<Map<String, int>>();

  controller.add(const <String, int>{'value': 10});
  controller.add(const <String, int>{'value': 8});
  new Timer(new Duration(milliseconds: 1), () {
    controller.addError(new Exception());
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.min', () async {
    const List<int> expectedOutput = const <int>[10, 3, 2, 1, 0];
    int count = 0;

    observable(_getStream()).min().listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.min.withCompare', () async {
    const List<int> expectedOutput = const <int>[10, 3, 3, 5, 2, 9, 1, 2, 0];
    int count = 0;

    observable(_getStream())
        .min((int a, int b) => -1)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.min.withCompare.withoutComparable', () async {
    const List<Map<String, int>> expectedOutput = const <Map<String, int>>[
      const <String, int>{'value': 10},
      const <String, int>{'value': 8}
    ];
    int count = 0;

    observable(_getErroneousStream())
        .min((Map<String, int> a, Map<String, int> b) =>
            a['value'].compareTo(b['value']))
        .listen(
            expectAsync1((Map<String, int> result) {
              expect(expectedOutput[count++], result);
            }, count: expectedOutput.length),
            onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.min.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream()).min();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.min.error.shouldThrow', () async {
    Stream<num> observableWithError = observable(getErroneousStream()).min();

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.min.error.comparator', () async {
    Stream<ErrorComparator> observableWithError =
        new Observable<ErrorComparator>.fromIterable(
                <ErrorComparator>[new ErrorComparator(), new ErrorComparator()])
            .min();

    observableWithError.listen((_) {}, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}

class ErrorComparator implements Comparable<ErrorComparator> {
  @override
  int compareTo(ErrorComparator other) {
    throw new Exception();
  }
}
