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
  test('rx.Observable.windowWhen', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .windowWhen(
            new Stream<Null>.periodic(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowWhen.asWindow', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .window(onStream(
            new Stream<Null>.periodic(const Duration(milliseconds: 220))))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowWhen.shouldClose', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .windowWhen(new Stream<Null>.periodic(const Duration(seconds: 3)))
        .asyncMap((s) => s.toList())
        .listen(
            expectAsync1((List<int> result) => expect(result, expectedOutput),
                count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.shouldClose.asWindow', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .window(onStream(new Stream<Null>.periodic(const Duration(seconds: 3))))
        .asyncMap((s) => s.toList())
        .listen(
            expectAsync1((List<int> result) => expect(result, expectedOutput),
                count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.reusable', () async {
    final transformer = new WindowWhenStreamTransformer<int>(
        new Stream<Null>.periodic(const Duration(milliseconds: 220))
            .asBroadcastStream());
    const expectedOutput = const [
      const [0, 1],
      const [2, 3]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    Stream<List<int>> streamB =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.reusable.asWindow', () async {
    final transformer = new WindowStreamTransformer<int>(onStream(
        new Stream<Null>.periodic(const Duration(milliseconds: 220))
            .asBroadcastStream()));
    const expectedOutput = const [
      const [0, 1],
      const [2, 3]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    Stream<List<int>> streamB =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.asBroadcastStream', () async {
    final stream = getStream(4)
        .windowWhen(
            new Stream<Null>.periodic(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.asBroadcastStream.asWindow', () async {
    final stream = getStream(4)
        .window(onStream(
            new Stream<Null>.periodic(const Duration(milliseconds: 220))))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .windowWhen(
                new Stream<Null>.periodic(const Duration(milliseconds: 220)))
            .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowWhen.error.shouldThrowA.asWindow', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .window(onStream(
                new Stream<Null>.periodic(const Duration(milliseconds: 220))))
            .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowWhen.error.shouldThrowB', () {
    expect(
        () => new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
            .windowWhen(null),
        throwsArgumentError);
  });

  test('rx.Observable.windowWhen.error.shouldThrowB.asWindow', () {
    // when using window, onCount is created asynchronously
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .window(onStream(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
