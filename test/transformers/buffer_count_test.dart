import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.bufferCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4).bufferCount(2);

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferCount.noSkip.asBuffer', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4).buffer(onCount(2));

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4).bufferCount(2, 1);

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.bufferCount.skip.asBuffer', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4).buffer(onCount(2, 1));

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.bufferCount.reusable', () async {
    final BufferStreamTransformer<int> transformer =
        new BufferStreamTransformer<int>(onCount(2));
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

  test('rx.Observable.bufferCount.asBroadcastStream', () async {
    Stream<List<int>> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .bufferCount(2);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferCount.asBroadcastStream.asBuffer', () async {
    Stream<List<int>> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .buffer(onCount(2));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferCount.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .bufferCount(2);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferCount.error.shouldThrowA.asBuffer', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .buffer(onCount(2));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferCount.skip.shouldThrowB', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .bufferCount(2, 100)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferCount.skip.shouldThrowB.asBuffer', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .buffer(onCount(2, 100))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferCount.skip.shouldThrowC', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .bufferCount(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferCount.skip.shouldThrowC.asBuffer', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .buffer(onCount(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
