import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.scan', () async {
    const List<int> expectedOutput = const <int>[1, 3, 6, 10];
    int count = 0;

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
        .scan((int acc, int value, int index) =>
            ((acc == null) ? 0 : acc) + value)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.scan.reusable', () async {
    final ScanStreamTransformer<int, int> transformer =
        new ScanStreamTransformer<int, int>((int acc, int value, int index) =>
            ((acc == null) ? 0 : acc) + value);
    const List<int> expectedOutput = const <int>[1, 3, 6, 10];
    int countA = 0, countB = 0;

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.scan.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .scan(
            (int acc, int value, int index) =>
                ((acc == null) ? 0 : acc) + value,
            0);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.scan.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .scan((num acc, num value, int index) {
      throw new StateError("oh noes!");
    });

    observableWithError.listen(null,
        onError: expectAsync2((StateError e, StackTrace s) {
          expect(e, isStateError);
        }, count: 4));
  });
}
