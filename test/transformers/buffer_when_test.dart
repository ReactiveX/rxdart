import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => Observable<int>((int n) async* {
      var k = 0;

      while (k < n) {
        await Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.bufferWhen', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .bufferWhen(Stream<Null>.periodic(const Duration(milliseconds: 220)))
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferWhen.asBuffer', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .buffer(
            onStream(Stream<Null>.periodic(const Duration(milliseconds: 220))))
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferWhen.sampleBeforeEvent.shouldEmit', () async {
    const expectedOutput = [
      <String>[],
      <String>[],
      <String>[],
      <String>[],
      ['done']
    ];
    var count = 0;

    Observable.fromFuture(
            Future<Null>.delayed(const Duration(milliseconds: 200))
                .then((_) => 'done'))
        .bufferWhen(Stream<Null>.periodic(const Duration(milliseconds: 40)))
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 5));
  });

  test('rx.Observable.bufferWhen.sampleBeforeEvent.shouldEmit.asBuffer',
      () async {
    const expectedOutput = [
      <String>[],
      <String>[],
      <String>[],
      <String>[],
      ['done']
    ];
    var count = 0;

    Observable.fromFuture(
            Future<Null>.delayed(const Duration(milliseconds: 200))
                .then((_) => 'done'))
        .buffer(
            onStream(Stream<Null>.periodic(const Duration(milliseconds: 40))))
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 5));
  });

  test('rx.Observable.bufferWhen.shouldClose', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .bufferWhen(Stream<Null>.periodic(const Duration(seconds: 3)))
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.bufferWhen.shouldClose.asBuffer', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .buffer(onStream(Stream<Null>.periodic(const Duration(seconds: 3))))
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.bufferWhen.reusable', () async {
    final transformer = BufferStreamTransformer<int>(onStream(
        Stream<Null>.periodic(const Duration(milliseconds: 220))
            .asBroadcastStream()));
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var countA = 0, countB = 0;

    final streamA = getStream(4).transform(transformer);

    streamA.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    final streamB = getStream(4).transform(transformer);

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.bufferWhen.asBroadcastStream', () async {
    final stream = getStream(4).asBroadcastStream().bufferWhen(
        Stream<Null>.periodic(const Duration(milliseconds: 220))
            .asBroadcastStream());

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.bufferWhen.asBroadcastStream.asBuffer', () async {
    final stream = getStream(4).asBroadcastStream().buffer(onStream(
        Stream<Null>.periodic(const Duration(milliseconds: 220))
            .asBroadcastStream()));

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  }, skip: 'todo: investigate why this test makes the process hang');

  test('rx.Observable.bufferWhen.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<Null>(Exception()))
        .bufferWhen(Stream<Null>.periodic(const Duration(milliseconds: 220)));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferWhen.error.shouldThrowA.asBuffer', () async {
    final observableWithError = Observable(ErrorStream<Null>(Exception()))
        .buffer(
            onStream(Stream<Null>.periodic(const Duration(milliseconds: 220))));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferWhen.error.shouldThrowB', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .bufferWhen<Null>(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferWhen.error.shouldThrowB.asBuffer', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .buffer(onStream<int, List<int>, void>(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
