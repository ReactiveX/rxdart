import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
  Stream<int> a = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

  return a;
}

void main() {
  test('rx.Observable.stream', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    int count = 0;

    Stream<int> stream = observable(_getStream());

    expect(stream is Stream<int>, true);
    expect(stream is Observable<int>, true);

    stream.listen(expectAsync1((int result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.stream.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.stream.error.shouldThrow', () async {
    Stream<num> observableWithError = observable(getErroneousStream());

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
