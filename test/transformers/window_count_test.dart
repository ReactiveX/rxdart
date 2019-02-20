import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.windowCount.noStartBufferEvery', () async {
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var count = 0;

    final stream =
        Observable.range(1, 4).windowCount(2).asyncMap((s) => s.toList());

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.noStartBufferEvery.asWindow', () async {
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var count = 0;

    final stream =
        Observable.range(1, 4).window(onCount(2)).asyncMap((s) => s.toList());

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.startBufferEvery.count2startBufferEvery1',
      () async {
    const expectedOutput = [
      [1, 2],
      [2, 3],
      [3, 4],
      [4]
    ];
    var count = 0;

    final stream =
        Observable.range(1, 4).windowCount(2, 1).asyncMap((s) => s.toList());

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.startBufferEvery.count3startBufferEvery2',
      () async {
    const expectedOutput = [
      [1, 2, 3],
      [3, 4, 5],
      [5, 6, 7],
      [7, 8]
    ];
    var count = 0;

    final stream =
        Observable.range(1, 8).windowCount(3, 2).asyncMap((s) => s.toList());

    bool equalLists(List<int> lA, List<int> lB) {
      for (var i = 0, len = lA.length; i < len; i++) {
        if (lA[i] != lB[i]) return false;
      }

      return true;
    }

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(equalLists(expectedOutput[count], result), isTrue);
      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.startBufferEvery.count3startBufferEvery4',
      () async {
    const expectedOutput = [
      [1, 2, 3],
      [5, 6, 7]
    ];
    var count = 0;

    final stream =
        Observable.range(1, 8).windowCount(3, 4).asyncMap((s) => s.toList());

    bool equalLists(List<int> lA, List<int> lB) {
      for (var i = 0, len = lA.length; i < len; i++) {
        if (lA[i] != lB[i]) return false;
      }

      return true;
    }

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(equalLists(expectedOutput[count], result), isTrue);
      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.startBufferEvery.asWindow', () async {
    const expectedOutput = [
      [1, 2],
      [2, 3],
      [3, 4],
      [4]
    ];
    var count = 0;

    final stream = Observable.range(1, 4)
        .window(onCount(2, 1))
        .asyncMap((s) => s.toList());

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.reusable', () async {
    final transformer = WindowStreamTransformer<int>(onCount(2));
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
    }, count: expectedOutput.length));

    final streamB = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer)
        .asyncMap((s) => s.toList());

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[countB][0], result[0]);
      expect(expectedOutput[countB][1], result[1]);
      countB++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.windowCount.asBroadcastStream', () async {
    final stream = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .windowCount(2)
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowCount.asBroadcastStream.asWindow', () async {
    final stream = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .window(onCount(2))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowCount.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .windowCount(2)
        .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowCount.error.shouldThrowA.asWindow', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .window(onCount(2))
        .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowCount.shouldThrow.invalidCount.negative', () {
    Observable<int>.fromIterable(const [1, 2, 3, 4])
        .windowCount(-1)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowCount.shouldThrow.invalidCount.isNull', () {
    Observable<int>.fromIterable(const [1, 2, 3, 4])
        .windowCount(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowCount.shouldThrow.invalidCount.negative.asBuffer',
      () {
    Observable<int>.fromIterable(const [1, 2, 3, 4])
        .window(onCount(-1))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowCount.shouldThrow.invalidCount.isNull.asBuffer',
      () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .window(onCount(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test(
      'rx.Observable.windowCount.startBufferEvery.shouldThrow.invalidStartBufferEvery',
      () {
    Observable<int>.fromIterable(const [1, 2, 3, 4])
        .windowCount(2, -1)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
