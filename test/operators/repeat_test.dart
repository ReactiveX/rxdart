import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

void main() {
  test('rx.Observable.repeat', () async {
    const List<int> expectedOutput = const <int>[1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    int count = 0;

    rx.observable(_getStream())
        .repeat(3)
        .listen(expectAsync1((int result) {
      expect(expectedOutput[count++], result);
    }, count: expectedOutput.length));
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
    Stream<num> observableWithError = rx.observable(getErroneousStream())
        .repeat(3);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
