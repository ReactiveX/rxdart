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
  test('rx.Observable.windowWhen', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .windowWhen(
            new Stream<Null>.periodic(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowWhen.asWindow', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .window(onStream(
            new Stream<Null>.periodic(const Duration(milliseconds: 220))))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowWhen.sampleBeforeEvent.shouldEmit.asBuffer',
      () async {
    const expectedOutput = [
      <String>[],
      <String>[],
      <String>[],
      <String>[],
      ['done']
    ];
    var count = 0;

    new Observable<String>.fromFuture(
            new Future<Null>.delayed(const Duration(milliseconds: 200))
                .then((_) => 'done'))
        .window(onStream(
            new Stream<Null>.periodic(const Duration(milliseconds: 40))))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 5));
  });

  test('rx.Observable.windowWhen.shouldClose', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .windowWhen(new Stream<Null>.periodic(const Duration(seconds: 3)))
        .asyncMap((s) => s.toList())
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.shouldClose.asWindow', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .window(onStream(new Stream<Null>.periodic(const Duration(seconds: 3))))
        .asyncMap((s) => s.toList())
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.reusable', () async {
    final transformer = new WindowStreamTransformer<int>(onStream(
        new Stream<Null>.periodic(const Duration(milliseconds: 220))
            .asBroadcastStream()));
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
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.asBroadcastStream', () async {
    final stream = getStream(4)
        .windowWhen(
            new Stream<Null>.periodic(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
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
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.windowWhen.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .windowWhen(
                new Stream<Null>.periodic(const Duration(milliseconds: 220)))
            .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowWhen.error.shouldThrowA.asWindow', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .window(onStream(
                new Stream<Null>.periodic(const Duration(milliseconds: 220))))
            .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowWhen.error.shouldThrowB', () {
    new Observable.fromIterable(const [1, 2, 3, 4])
        .windowWhen<Null>(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowWhen.error.shouldThrowB.asWindow', () {
    new Observable.fromIterable(const [1, 2, 3, 4])
        .window(onStream<int, Stream<int>, void>(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
