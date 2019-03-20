import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.windowCount.noStartBufferEvery', () async {
    await expectLater(
        Observable.range(1, 4)
            .windowCount(2)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          [1, 2],
          [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.windowCount.noStartBufferEvery.includesEventOnClose',
      () async {
    await expectLater(
        Observable.range(1, 5)
            .windowCount(2)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          const [5],
          emitsDone
        ]));
  });

  test('rx.Observable.windowCount.startBufferEvery.count2startBufferEvery1',
      () async {
    await expectLater(
        Observable.range(1, 4)
            .windowCount(2, 1)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [2, 3],
          const [3, 4],
          const [4],
          emitsDone
        ]));
  });

  test('rx.Observable.windowCount.startBufferEvery.count3startBufferEvery2',
      () async {
    await expectLater(
        Observable.range(1, 8)
            .windowCount(3, 2)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2, 3],
          const [3, 4, 5],
          const [5, 6, 7],
          const [7, 8],
          emitsDone
        ]));
  });

  test('rx.Observable.windowCount.startBufferEvery.count3startBufferEvery4',
      () async {
    await expectLater(
        Observable.range(1, 8)
            .windowCount(3, 4)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2, 3],
          const [5, 6, 7],
          emitsDone
        ]));
  });

  test('rx.Observable.windowCount.reusable', () async {
    final transformer = WindowCountStreamTransformer<int>(2);

    await expectLater(
        Observable(Stream.fromIterable(const [1, 2, 3, 4]))
            .transform(transformer)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));

    await expectLater(
        Observable(Stream.fromIterable(const [1, 2, 3, 4]))
            .transform(transformer)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.windowCount.asBroadcastStream', () async {
    final stream =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]).asBroadcastStream())
            .windowCount(2)
            .ignoreElements();

    // listen twice on same stream
    await expectLater(stream, emitsDone);
    await expectLater(stream, emitsDone);
  });

  test('rx.Observable.windowCount.error.shouldThrowA', () async {
    await expectLater(Observable(ErrorStream<void>(Exception())).windowCount(2),
        emitsError(isException));
  });

  test(
    'rx.Observable.windowCount.shouldThrow.invalidCount.negative',
    () {
      expect(() => Observable.fromIterable(const [1, 2, 3, 4]).windowCount(-1),
          throwsArgumentError);
    },
  );

  test('rx.Observable.windowCount.shouldThrow.invalidCount.isNull', () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).windowCount(null),
        throwsArgumentError);
  });

  test(
      'rx.Observable.windowCount.startBufferEvery.shouldThrow.invalidStartBufferEvery',
      () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).windowCount(2, -1),
        throwsArgumentError);
  });
}
