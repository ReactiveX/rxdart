import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 20), (int count) => count).take(5);
Stream<int> _getSampleStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 35), (int count) => count).take(5);

void main() {
  test('rx.Observable.sample', () async {
    const List<int> expectedOutput = const <int>[0, 2, 4, 4, 4];
    int count = 0;

    rx
        .observable(_getStream())
        .sample(_getSampleStream())
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    Stream<int> observable = rx
        .observable(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.sample.error.shouldThrow', () async {
    Stream<num> observableWithError =
        rx.observable(getErroneousStream()).sample(_getSampleStream());

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
