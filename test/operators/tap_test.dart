import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.tap', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    List<int> actualOutput = <int>[];
    int count = 0;

    observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
        .tap((int value) => actualOutput.add(value))
        .listen(expectAsync1((_) {
          expect(actualOutput[count], expectedOutput[count++]);
    }, count: 4));
  });

  test('rx.Observable.tap.asBroadcastStream', () async {
    Stream<int> stream =
        observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream()).tap((_) {});

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
