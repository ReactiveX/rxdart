import 'dart:async';
import 'package:collection/collection.dart';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Observable<int> getStream(int n) => new Observable((int n) async* {
      int k = 0;

      while (k < n) {
        await new Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.bufferWithTimeframe', () async {
    const expectedOutput = const [
      const [0, 1],
      const [2, 3]
    ];
    int count = 0;

    getStream(4)
        .bufferWithTimeframe(const Duration(milliseconds: 220))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(
              const IterableEquality<int>()
                  .equals(result, expectedOutput[count++]),
              isTrue);
        }, count: 2));
  });

  test('rx.Observable.bufferWithTimeframe', () async {
    const expectedOutput = const [0, 1, 2, 3];
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .bufferWithTimeframe(const Duration(days: 1))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(const IterableEquality<int>().equals(result, expectedOutput),
              isTrue);
        }, count: 1));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferWithTimeframe.reusable', () async {
    final transformer = new BufferWithTimeframeStreamTransformer<int>(
        const Duration(milliseconds: 220));
    const expectedOutput = const [
      const [0, 1],
      const [2, 3]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA = getStream(4).transform(transformer);

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(
          const IterableEquality<int>()
              .equals(result, expectedOutput[countA++]),
          isTrue);
    }, count: 2));

    Stream<List<int>> streamB = getStream(4).transform(transformer);

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(
          const IterableEquality<int>()
              .equals(result, expectedOutput[countB++]),
          isTrue);
    }, count: 2));
  });

  test('rx.Observable.bufferWithTimeframe.asBroadcastStream', () async {
    final stream = getStream(4)
        .asBroadcastStream()
        .bufferWithTimeframe(const Duration(milliseconds: 220));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferWithTimeframe.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .bufferWithTimeframe(const Duration(milliseconds: 220));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferWithTimeframe.skip.shouldThrowB', () {
    expect(() => getStream(4).bufferWithTimeframe(null), throwsArgumentError);
  });
}
