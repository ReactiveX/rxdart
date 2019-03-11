import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

/// yield immediately, then every 100ms
Observable<int> getStream(int n) => Observable<int>((int n) async* {
      var k = 1;

      yield 0;

      while (k < n) {
        yield await Future<Null>.delayed(const Duration(milliseconds: 100))
            .then((_) => k++);
      }
    }(n));

void main() {
  test('rx.Observable.bufferFuture', () async {
    // elapsedMs: event
    //         0: 0
    //       100: 1
    //       160: buffer: [0, 1]
    //       200: 2
    //       300: 3
    //       320: buffer: [2, 3]
    await expectLater(
        getStream(4).bufferFuture(
            () => Future<Null>.delayed(const Duration(milliseconds: 160))),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferFuture.asBuffer', () async {
    await expectLater(
        getStream(4).buffer(onFuture(
            () => Future<Null>.delayed(const Duration(milliseconds: 160)))),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferFuture.sampleBeforeEvent.shouldEmit', () async {
    final stream = () async* {
      yield 'start';

      await Future<void>.delayed(const Duration(milliseconds: 200));
    };

    await expectLater(
        Observable(stream()).bufferFuture(
            () => Future<Null>.delayed(const Duration(milliseconds: 40))),
        emitsInOrder(<dynamic>[
          ['start'], // buffer 0 -> 40ms
          <String>[], // buffer 40ms -> 80ms
          <String>[], // buffer 80ms -> 120ms
          <String>[], // buffer 120ms -> 160ms
          <String>[], // final buffer
          emitsDone
        ]));
  });

  test('rx.Observable.bufferFuture.sampleBeforeEvent.shouldEmit.asBuffer',
      () async {
    final stream = () async* {
      yield 'start';

      await Future<void>.delayed(const Duration(milliseconds: 200));
    };

    await expectLater(
        Observable(stream()).buffer(onFuture(
            () => Future<Null>.delayed(const Duration(milliseconds: 40)))),
        emitsInOrder(<dynamic>[
          ['start'], // buffer 0 -> 40ms
          <String>[], // buffer 40ms -> 80ms
          <String>[], // buffer 80ms -> 120ms
          <String>[], // buffer 120ms -> 160ms
          <String>[], // final buffer
          emitsDone
        ]));
  });

  test('rx.Observable.bufferFuture.shouldClose', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .bufferFuture(() => Future<Null>.delayed(const Duration(seconds: 3)))
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferFuture.shouldClose.asBuffer', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .buffer(
            onFuture(() => Future<Null>.delayed(const Duration(seconds: 3))))
        .listen(
            expectAsync1((result) => expect(result, expectedOutput), count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferFuture.reusable', () async {
    final transformer = BufferStreamTransformer<int>(onFuture(
        () => Future<Null>.delayed(const Duration(milliseconds: 160))));

    await expectLater(
        getStream(4).transform(transformer),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));

    await expectLater(
        getStream(4).transform(transformer),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferFuture.asBroadcastStream', () async {
    final stream = getStream(4).asBroadcastStream().bufferFuture(
        () => Future<Null>.delayed(const Duration(milliseconds: 160)));

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferFuture.asBroadcastStream.asBuffer', () async {
    final stream = getStream(4).asBroadcastStream().buffer(onFuture(
        () => Future<Null>.delayed(const Duration(milliseconds: 160))));

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferFuture.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<Null>(Exception()))
        .bufferFuture(
            () => Future<Null>.delayed(const Duration(milliseconds: 160)));

    observableWithError.listen(null,
        onError: expectAsync2((Object e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferFuture.error.shouldThrowA.asBuffer', () async {
    final observableWithError = Observable(ErrorStream<Null>(Exception()))
        .buffer(onFuture(
            () => Future<Null>.delayed(const Duration(milliseconds: 160))));

    observableWithError.listen(null,
        onError: expectAsync2((Object e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferFuture.error.shouldThrowB', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .bufferFuture<Null>(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferFuture.error.shouldThrowB.asFuture', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .buffer(onFuture<int, List<int>, void>(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
