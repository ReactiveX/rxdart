import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.bufferTest', () async {
    await expectLater(
        Observable.range(1, 4).bufferTest((i) => i % 2 == 0),
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferTest.reusable', () async {
    final transformer = BufferTestStreamTransformer<int>((i) => i % 2 == 0);

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

  test('rx.Observable.bufferTest.asBroadcastStream', () async {
    final stream =
        Observable(Stream.fromIterable(const [1, 2, 3, 4]).asBroadcastStream())
            .bufferTest((i) => i % 2 == 0);

    // listen twice on same stream
    await expectLater(
        stream,
        emitsInOrder(<dynamic>[
          const [1, 2],
          const [3, 4],
          emitsDone
        ]));

    await expectLater(stream, emitsDone);
  });

  test('rx.Observable.bufferTest.error.shouldThrowA', () async {
    await expectLater(
        Observable(ErrorStream<int>(Exception())).bufferTest((i) => i % 2 == 0),
        emitsError(isException));
  });

  test('rx.Observable.bufferTest.skip.shouldThrowB', () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).bufferTest(null),
        throwsArgumentError);
  });
}
