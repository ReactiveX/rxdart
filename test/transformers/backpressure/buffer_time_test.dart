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
  test('rx.Observable.bufferTime', () async {
    await expectLater(
        getStream(4).bufferTime(const Duration(milliseconds: 160)),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));
  });

  test('rx.Observable.bufferTime.shouldClose', () async {
    final controller = StreamController<int>()..add(0)..add(1)..add(2)..add(3);

    scheduleMicrotask(controller.close);

    await expectLater(
        Observable(controller.stream)
            .bufferTime(const Duration(seconds: 3))
            .take(1),
        emitsInOrder(<dynamic>[
          const [0, 1, 2, 3], // done
          emitsDone
        ]));
  });

  test('rx.Observable.bufferTime.reusable', () async {
    final transformer = BufferStreamTransformer<int>(
        (_) => Stream<void>.periodic(const Duration(milliseconds: 160)));

    await expectLater(
        getStream(4).transform(transformer),
        emitsInOrder(<dynamic>[
          const [0, 1], const [2, 3], // done
          emitsDone
        ]));

    await expectLater(
        getStream(4).transform(transformer),
        emitsInOrder(<dynamic>[
          const [0, 1], const [2, 3], // done
          emitsDone
        ]));
  });

  test('rx.Observable.bufferTime.asBroadcastStream', () async {
    final stream = getStream(4)
        .asBroadcastStream()
        .bufferTime(const Duration(milliseconds: 160));

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

  test('rx.Observable.bufferTime.error.shouldThrowA', () async {
    await expectLater(
        Observable(ErrorStream<void>(Exception()))
            .bufferTime(const Duration(milliseconds: 160)),
        emitsError(isException));
  });

  test('rx.Observable.bufferTime.error.shouldThrowB', () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).bufferTime(null),
        throwsArgumentError);
  });
}
