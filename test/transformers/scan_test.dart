import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.scan', () async {
    const expectedOutput = [1, 3, 6, 10];
    var count = 0;

    Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .scan((int acc, int value, int index) => (acc ?? 0) + value)
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.scan.reusable', () async {
    final transformer = ScanStreamTransformer<int, int>(
        (int acc, int value, int index) => (acc ?? 0) + value);
    const expectedOutput = [1, 3, 6, 10];
    var countA = 0, countB = 0;

    Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.scan.asBroadcastStream', () async {
    final stream =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]).asBroadcastStream())
            .scan((int acc, int value, int index) => (acc ?? 0) + value, 0);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.scan.error.shouldThrow', () async {
    final observableWithError =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]))
            .scan((num acc, num value, int index) {
      throw StateError("oh noes!");
    });

    observableWithError.listen(null,
        onError: expectAsync2((StateError e, StackTrace s) {
          expect(e, isStateError);
        }, count: 4));
  });
}
