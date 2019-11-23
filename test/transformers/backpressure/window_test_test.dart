import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.windowTest', () async {
    await expectLater(
        Observable.range(1, 4)
            .windowTest((i) => i % 2 == 0)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.windowTest.reusable', () async {
    final transformer = WindowTestStreamTransformer<int>((i) => i % 2 == 0);

    await expectLater(
        Stream.fromIterable(const [1, 2, 3, 4])
            .transform(transformer)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));

    await expectLater(
        Stream.fromIterable(const [1, 2, 3, 4])
            .transform(transformer)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.windowTest.asBroadcastStream', () async {
    final stream = Stream.fromIterable(const [1, 2, 3, 4])
        .asBroadcastStream()
        .windowTest((i) => i % 2 == 0)
        .ignoreElements();

    // listen twice on same stream
    await expectLater(stream, emitsDone);
    await expectLater(stream, emitsDone);
  });

  test('rx.Observable.windowTest.error.shouldThrowA', () async {
    await expectLater(
        Stream<int>.error(Exception()).windowTest((i) => i % 2 == 0),
        emitsError(isException));
  });

  test('rx.Observable.windowTest.skip.shouldThrowB', () {
    expect(() => Stream.fromIterable(const [1, 2, 3, 4]).windowTest(null),
        throwsArgumentError);
  });
}
