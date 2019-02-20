import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.windowTest', () async {
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var count = 0;

    final stream = Observable.range(1, 4)
        .windowTest((i) => i % 2 == 0)
        .asyncMap((s) => s.toList());

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.windowTest.asWindow', () async {
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var count = 0;

    final stream = Observable.range(1, 4)
        .window(onTest((i) => i % 2 == 0))
        .asyncMap((s) => s.toList());

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.windowTest.reusable', () async {
    final transformer = WindowStreamTransformer<int>(onTest((i) => i % 2 == 0));
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var countA = 0, countB = 0;

    final streamA = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer)
        .asyncMap((s) => s.toList());

    streamA.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[countA][0], result[0]);
      expect(expectedOutput[countA][1], result[1]);
      countA++;
    }, count: 2));

    final streamB = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer)
        .asyncMap((s) => s.toList());

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[countB][0], result[0]);
      expect(expectedOutput[countB][1], result[1]);
      countB++;
    }, count: 2));
  });

  test('rx.Observable.windowTest.asBroadcastStream', () async {
    final stream = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .windowTest((i) => i % 2 == 0)
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowTest.asBroadcastStream.asWindow', () async {
    final stream = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .window(onTest((i) => i % 2 == 0))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowTest.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .windowTest((i) => i % 2 == 0)
        .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowTest.error.shouldThrowA.asWindow', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .window(onTest((i) => i % 2 == 0))
        .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowTest.skip.shouldThrowB', () {
    Observable.fromIterable(const [1, 2, 3, 4]).windowTest(null).listen(null,
        onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowTest.skip.shouldThrowB.asWindow', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .window(onTest(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
