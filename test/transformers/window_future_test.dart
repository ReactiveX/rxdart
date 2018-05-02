import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => new Observable<int>((int n) async* {
      int k = 0;

      while (k < n) {
        await new Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.windowFuture', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .windowFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)))
        .asyncMap((Stream<int> s) => s.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowFuture.asWindow', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .window(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))))
        .asyncMap((Stream<int> s) => s.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowFuture.shouldClose', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .windowFuture(
            () => new Future<Null>.delayed(const Duration(seconds: 3)))
        .asyncMap((Stream<int> s) => s.toList())
        .listen(
            expectAsync1((List<int> result) => expect(result, expectedOutput),
                count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.windowFuture.shouldClose.asWindow', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .window(onFuture(
            () => new Future<Null>.delayed(const Duration(seconds: 3))))
        .asyncMap((Stream<int> s) => s.toList())
        .listen(
            expectAsync1((List<int> result) => expect(result, expectedOutput),
                count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.windowFuture.reusable', () async {
    final StreamTransformer<int, Stream<int>> transformer =
        new WindowStreamTransformer<int>(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))));
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA = getStream(4)
        .transform(transformer)
        .asyncMap((Stream<int> s) => s.toList());

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    Stream<List<int>> streamB = getStream(4)
        .transform(transformer)
        .asyncMap((Stream<int> s) => s.toList());

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  });

  test('rx.Observable.windowFuture.asBroadcastStream', () async {
    final Stream<List<int>> stream = getStream(4)
        .windowFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)))
        .asyncMap((Stream<int> s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowFuture.asBroadcastStream.asWindow', () async {
    final Stream<List<int>> stream = getStream(4)
        .window(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))))
        .asyncMap((Stream<int> s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowFuture.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .windowFuture(() =>
                new Future<Null>.delayed(const Duration(milliseconds: 220)))
            .asyncMap((Stream<num> s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowFuture.error.shouldThrowA.asWindow', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .window(onFuture(() =>
                new Future<Null>.delayed(const Duration(milliseconds: 220))))
            .asyncMap((Stream<num> s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowFuture.error.shouldThrowB', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .windowFuture<Null>(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowFuture.error.shouldThrowB.asFuture', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .window(onFuture<int, Stream<int>, Null>(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
