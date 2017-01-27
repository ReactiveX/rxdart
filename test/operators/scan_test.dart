import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.scan', () async {
    const List<int> expectedOutput = const <int>[1, 3, 6, 10];
    int count = 0;

    observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
        .scan((int acc, int value, int index) =>
            ((acc == null) ? 0 : acc) + value)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.scan.asBroadcastStream', () async {
    Stream<int> stream = observable(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .scan(
            (int acc, int value, int index) =>
                ((acc == null) ? 0 : acc) + value,
            0);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.scan.error.shouldThrow', () async {
    Stream<int> observableWithError =
        observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .scan((num acc, num value, int index) {
      throw new StateError("oh noes!");
    });

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e, isStateError);
        }, count: 4));
  });
}
