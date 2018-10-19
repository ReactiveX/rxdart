import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => new Observable<int>((int n) async* {
      var k = 0;

      while (k < n) {
        await new Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.windowFuture', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .windowFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowFuture.asWindow', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .window(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowFuture.shouldClose', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .windowFuture(
            () => new Future<Null>.delayed(const Duration(seconds: 3)))
        .asyncMap((s) => s.toList())
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.windowFuture.shouldClose.asWindow', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .window(onFuture(
            () => new Future<Null>.delayed(const Duration(seconds: 3))))
        .asyncMap((s) => s.toList())
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.windowFuture.reusable', () async {
    final transformer = new WindowStreamTransformer<int>(onFuture(
        () => new Future<Null>.delayed(const Duration(milliseconds: 220))));
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var countA = 0, countB = 0;

    final streamA =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamA.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    final streamB =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  });

  test('rx.Observable.windowFuture.asBroadcastStream', () async {
    final stream = getStream(4)
        .windowFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowFuture.asBroadcastStream.asWindow', () async {
    final stream = getStream(4)
        .window(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowFuture.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<Null>(new Exception()))
            .windowFuture(() =>
                new Future<Null>.delayed(const Duration(milliseconds: 220)))
            .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowFuture.error.shouldThrowA.asWindow', () async {
    final observableWithError =
        new Observable(new ErrorStream<Null>(new Exception()))
            .window(onFuture(() =>
                new Future<Null>.delayed(const Duration(milliseconds: 220))))
            .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowFuture.error.shouldThrowB', () {
    new Observable.fromIterable(const [1, 2, 3, 4])
        .windowFuture<Null>(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowFuture.error.shouldThrowB.asFuture', () {
    new Observable.fromIterable(const [1, 2, 3, 4])
        .window(onFuture<int, Stream<int>, void>(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
