import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.bufferTest', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream =
        Observable.range(1, 4).bufferTest((int i) => i % 2 == 0);

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferTest.asBuffer', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<List<int>> stream =
        Observable.range(1, 4).buffer(onTest((int i) => i % 2 == 0));

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count][0], result[0]);
      expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 2));
  });

  test('rx.Observable.bufferTest.reusable', () async {
    final BufferStreamTransformer<int> transformer =
        new BufferStreamTransformer<int>(onTest((int i) => i % 2 == 0));
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

  test('rx.Observable.bufferTest.asBroadcastStream', () async {
    Stream<List<int>> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .bufferTest((int i) => i % 2 == 0);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTest.asBroadcastStream.asBuffer', () async {
    Stream<List<int>> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .buffer(onTest((int i) => i % 2 == 0));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTest.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .bufferTest((num i) => i % 2 == 0);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTest.error.shouldThrowA.asBuffer', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .buffer(onTest((num i) => i % 2 == 0));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTest.skip.shouldThrowB', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .bufferTest(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferTest.skip.shouldThrowB.asBuffer', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .buffer(onTest(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
