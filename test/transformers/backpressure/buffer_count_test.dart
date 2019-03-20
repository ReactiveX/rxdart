import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.bufferCount.noStartBufferEvery', () async {
    await expectLater(
        Observable.range(1, 4).bufferCount(2),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferCount.noStartBufferEvery.includesEventOnClose',
      () async {
    await expectLater(
        Observable.range(1, 5).bufferCount(2),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          const [5],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferCount.startBufferEvery.count2startBufferEvery1',
      () async {
    await expectLater(
        Observable.range(1, 4).bufferCount(2, 1),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [2, 3],
          const [3, 4],
          const [4],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferCount.startBufferEvery.count3startBufferEvery2',
      () async {
    await expectLater(
        Observable.range(1, 8).bufferCount(3, 2),
        emitsInOrder(<dynamic>[
          const [1, 2, 3],
          const [3, 4, 5],
          const [5, 6, 7],
          const [7, 8],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferCount.startBufferEvery.count3startBufferEvery4',
      () async {
    await expectLater(
        Observable.range(1, 8).bufferCount(3, 4),
        emitsInOrder(<dynamic>[
          const [1, 2, 3],
          const [5, 6, 7],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferCount.reusable', () async {
    final transformer = BufferCountStreamTransformer<int>(2);

    await expectLater(
        Observable(Stream.fromIterable(const [1, 2, 3, 4]))
            .transform(transformer),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));

    await expectLater(
        Observable(Stream.fromIterable(const [1, 2, 3, 4]))
            .transform(transformer),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferCount.asBroadcastStream', () async {
    final stream =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]).asBroadcastStream())
            .bufferCount(2);

    // listen twice on same stream
    await expectLater(
        stream,
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));

    await expectLater(stream, emitsInOrder(<dynamic>[emitsDone]));
  });

  test('rx.Observable.bufferCount.error.shouldThrowA', () async {
    await expectLater(Observable(ErrorStream<void>(Exception())).bufferCount(2),
        emitsError(isException));
  });

  test(
    'rx.Observable.bufferCount.shouldThrow.invalidCount.negative',
    () {
      expect(() => Observable.fromIterable(const [1, 2, 3, 4]).bufferCount(-1),
          throwsArgumentError);
    },
  );

  test('rx.Observable.bufferCount.shouldThrow.invalidCount.isNull', () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).bufferCount(null),
        throwsArgumentError);
  });

  test(
      'rx.Observable.bufferCount.startBufferEvery.shouldThrow.invalidStartBufferEvery',
      () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).bufferCount(2, -1),
        throwsArgumentError);
  });
}
