import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => new Observable((int n) async* {
      int k = 0;

      while (k < n) {
        await new Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.windowTime', () async {
    const expectedOutput = const [
      const [0, 1],
      const [2, 3]
    ];
    int count = 0;

    getStream(4)
        .windowTime(const Duration(milliseconds: 220))
        .asyncMap((buffer) => buffer.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowTime', () async {
    const expectedOutput = const [0, 1, 2, 3];
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .windowTime(const Duration(seconds: 3))
        .asyncMap((buffer) => buffer.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput);
        }, count: 1));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.windowTime.reusable', () async {
    final transformer =
        new WindowTimeStreamTransformer<int>(const Duration(milliseconds: 220));
    const expectedOutput = const [
      const [0, 1],
      const [2, 3]
    ];
    int countA = 0, countB = 0;

    Stream<Stream<int>> streamA = getStream(4).transform(transformer);

    streamA
        .asyncMap((buffer) => buffer.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[countA++]);
        }, count: 2));

    Stream<Stream<int>> streamB = getStream(4).transform(transformer);

    streamB
        .asyncMap((buffer) => buffer.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[countB++]);
        }, count: 2));
  });

  test('rx.Observable.windowTime.asBroadcastStream', () async {
    final stream = getStream(4)
        .asBroadcastStream()
        .windowTime(const Duration(milliseconds: 220));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowTime.error.shouldThrowA', () async {
    Stream<Stream<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .windowTime(const Duration(milliseconds: 220));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowTime.skip.shouldThrowB', () {
    expect(() => getStream(4).windowTime(null), throwsArgumentError);
  });
}
