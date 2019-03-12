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
  test('rx.Observable.windowTime', () async {
    await expectLater(
        getStream(4)
            .windowTime(const Duration(milliseconds: 160))
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [0, 1],
          const [2, 3],
          emitsDone
        ]));
  });

  test('rx.Observable.windowTime.shouldClose', () async {
    final controller = StreamController<int>()..add(0)..add(1)..add(2)..add(3);

    scheduleMicrotask(controller.close);

    await expectLater(
        Observable(controller.stream)
            .windowTime(const Duration(seconds: 3))
            .asyncMap((stream) => stream.toList())
            .take(1),
        emitsInOrder(<dynamic>[
          const [0, 1, 2, 3], // done
          emitsDone
        ]));
  });

  test('rx.Observable.windowTime.reusable', () async {
    final transformer = WindowStreamTransformer<int>(
        (_) => Stream<void>.periodic(const Duration(milliseconds: 160)));

    await expectLater(
        getStream(4)
            .transform(transformer)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [0, 1], const [2, 3], // done
          emitsDone
        ]));

    await expectLater(
        getStream(4)
            .transform(transformer)
            .asyncMap((stream) => stream.toList()),
        emitsInOrder(<dynamic>[
          const [0, 1], const [2, 3], // done
          emitsDone
        ]));
  });

  test('rx.Observable.windowTime.asBroadcastStream', () async {
    final stream = getStream(4)
        .asBroadcastStream()
        .windowTime(const Duration(milliseconds: 160))
        .ignoreElements();

    // listen twice on same stream
    await expectLater(stream, emitsDone);
    await expectLater(stream, emitsDone);
  });

  test('rx.Observable.windowTime.error.shouldThrowA', () async {
    await expectLater(
        Observable(ErrorStream<void>(Exception()))
            .windowTime(const Duration(milliseconds: 160)),
        emitsError(isException));
  });

  test('rx.Observable.windowTime.error.shouldThrowB', () {
    expect(() => Observable.fromIterable(const [1, 2, 3, 4]).windowTime(null),
        throwsArgumentError);
  });
}
