import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.windowCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4)
        .windowCount(2)
        .asyncMap((Stream<int> s) => s.toList());

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.windowCount.noSkip.asWindow', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4)
        .window(onCount(2))
        .asyncMap((Stream<int> s) => s.toList());

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.windowCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4)
        .windowCount(2, 1)
        .asyncMap((Stream<int> s) => s.toList());

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.windowCount.skip.asWindow', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<List<int>> stream = Observable.range(1, 4)
        .window(onCount(2, 1))
        .asyncMap((Stream<int> s) => s.toList());

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.windowCount.reusable', () async {
    final WindowStreamTransformer<int> transformer =
        new WindowStreamTransformer<int>(onCount(2));
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .transform(transformer)
            .asyncMap((Stream<int> s) => s.toList());

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[countA][0], result[0]);
      expect(expectedOutput[countA][1], result[1]);
      countA++;
    }, count: 2));

    Stream<List<int>> streamB =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .transform(transformer)
            .asyncMap((Stream<int> s) => s.toList());

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[countB][0], result[0]);
      expect(expectedOutput[countB][1], result[1]);
      countB++;
    }, count: 2));
  });

  test('rx.Observable.windowCount.asBroadcastStream', () async {
    Stream<List<int>> stream =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .windowCount(2)
            .asyncMap((Stream<int> s) => s.toList())
            .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowCount.asBroadcastStream.asWindow', () async {
    Stream<List<int>> stream =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .window(onCount(2))
            .asyncMap((Stream<int> s) => s.toList())
            .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowCount.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .windowCount(2)
            .asyncMap((Stream<num> s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowCount.error.shouldThrowA.asWindow', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .window(onCount(2))
            .asyncMap((Stream<num> s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowCount.skip.shouldThrowB', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .windowCount(2, 100)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowCount.skip.shouldThrowB.asWindow', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .window(onCount(2, 100))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowCount.skip.shouldThrowC', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .windowCount(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowCount.skip.shouldThrowC.asWindow', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .window(onCount(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
