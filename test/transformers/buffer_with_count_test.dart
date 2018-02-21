import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.bufferWithCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4).bufferWithCount(2);

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferWithCount.reusable', () async {
    final BufferWithCountStreamTransformer<int> transformer =
        new BufferWithCountStreamTransformer<int>(2);
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .transform(transformer);

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[countA][0], result[0]);
      expect(expectedOutput[countA][1], result[1]);
      countA++;
    }, count: 2));

    Stream<List<int>> streamB =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .transform(transformer);

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[countB][0], result[0]);
      expect(expectedOutput[countB][1], result[1]);
      countB++;
    }, count: 2));
  });

  test('rx.Observable.bufferWithCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4).bufferWithCount(2, 1);

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.bufferWithCount.asBroadcastStream', () async {
    Stream<List<int>> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .bufferWithCount(2);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(true, true);
  });

  test('rx.Observable.bufferWithCount.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .bufferWithCount(2);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferWithCount.skip.shouldThrowB', () {
    expect(
        () => new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
            .bufferWithCount(2, 100),
        throwsArgumentError);
  });

  test('rx.Observable.bufferWithCount.skip.shouldThrowC', () {
    expect(
        () => new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
            .bufferWithCount(null),
        throwsArgumentError);
  });
}
