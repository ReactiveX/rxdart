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
  test('rx.Observable.buffer', () async {
    await expectLater(
        getStream(4).buffer(
            Stream<Null>.periodic(const Duration(milliseconds: 160)).take(3)),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));
  });

  test('rx.Observable.buffer.sampleBeforeEvent.shouldEmit', () async {
    await expectLater(
        Observable.fromFuture(
            Future<Null>.delayed(const Duration(milliseconds: 200))
                .then((_) => 'end')).startWith('start').buffer(
            Stream<Null>.periodic(const Duration(milliseconds: 40)).take(10)),
        emitsInOrder(<dynamic>[
          const ['start'], // after 40ms
          const <String>[], // 80ms
          const <String>[], // 120ms
          const <String>[], // 160ms
          const ['end'], // done
          emitsDone
        ]));
  });

  test('rx.Observable.buffer.shouldClose', () async {
    final controller = StreamController<int>()..add(0)..add(1)..add(2)..add(3);

    scheduleMicrotask(controller.close);

    await expectLater(
        Observable(controller.stream)
            .buffer(Stream<Null>.periodic(const Duration(seconds: 3)))
            .take(1),
        emitsInOrder(<dynamic>[
          const [0, 1, 2, 3], // done
          emitsDone
        ]));
  });

  test('rx.Observable.buffer.reusable', () async {
    final transformer = BufferStreamTransformer<int>((_) =>
        Stream<Null>.periodic(const Duration(milliseconds: 160))
            .take(3)
            .asBroadcastStream());

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

  test('rx.Observable.buffer.asBroadcastStream', () async {
    final stream = getStream(4).asBroadcastStream().buffer(
        Stream<Null>.periodic(const Duration(milliseconds: 160))
            .take(10)
            .asBroadcastStream());

    // listen twice on same stream
    await expectLater(
        stream,
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));

    await expectLater(
        stream, emitsInOrder(<dynamic>[const <int>[], emitsDone]));
  });

  test('rx.Observable.buffer.error.shouldThrowA', () async {
    await expectLater(
        Observable(ErrorStream<Null>(Exception()))
            .buffer(Stream<Null>.periodic(const Duration(milliseconds: 160))),
        emitsError(isException));
  });

  test('rx.Observable.buffer.error.shouldThrowB', () async {
    await expectLater(Observable.fromIterable(const [1, 2, 3, 4]).buffer(null),
        emitsError(isArgumentError));
  });
}
