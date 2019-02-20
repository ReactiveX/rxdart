import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.bufferTest', () async {
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var count = 0;

    final stream = Observable.range(1, 4).bufferTest((i) => i % 2 == 0);

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferTest.asBuffer', () async {
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var count = 0;

    final stream = Observable.range(1, 4).buffer(onTest((i) => i % 2 == 0));

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferTest.reusable', () async {
    final transformer = BufferStreamTransformer<int>(onTest((i) => i % 2 == 0));
    const expectedOutput = [
      [1, 2],
      [3, 4]
    ];
    var countA = 0, countB = 0;

    final streamA = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer);

    streamA.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[countA][0], result[0]);
      expect(expectedOutput[countA][1], result[1]);
      countA++;
    }, count: 2));

    final streamB = Observable(Stream.fromIterable(const [1, 2, 3, 4]))
        .transform(transformer);

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(expectedOutput[countB][0], result[0]);
      expect(expectedOutput[countB][1], result[1]);
      countB++;
    }, count: 2));
  });

  test('rx.Observable.bufferTest.asBroadcastStream', () async {
    final stream =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]).asBroadcastStream())
            .bufferTest((i) => i % 2 == 0);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTest.asBroadcastStream.asBuffer', () async {
    final stream =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]).asBroadcastStream())
            .buffer(onTest((i) => i % 2 == 0));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTest.error.shouldThrowA', () async {
    final observableWithError =
        Observable(ErrorStream<int>(Exception())).bufferTest((i) => i % 2 == 0);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTest.error.shouldThrowA.asBuffer', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .buffer(onTest((i) => i % 2 == 0));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTest.skip.shouldThrowB', () {
    Observable.fromIterable(const [1, 2, 3, 4]).bufferTest(null).listen(null,
        onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferTest.skip.shouldThrowB.asBuffer', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .buffer(onTest(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
