import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    Stream<int>.periodic(const Duration(milliseconds: 20), (count) => count)
        .take(5);

void main() {
  test('rx.Observable.sampleTime', () async {
    final observable =
        Observable(_getStream()).sampleTime(const Duration(milliseconds: 35));

    await expectLater(observable, emitsInOrder(<dynamic>[1, 3, 4, emitsDone]));
  });

  test('rx.Observable.sampleTime.reusable', () async {
    final transformer = SampleStreamTransformer<int>((_) =>
        TimerStream<bool>(true, const Duration(milliseconds: 35))
            .asBroadcastStream());

    await expectLater(
        Observable(_getStream()).transform(transformer).ignoreElements(),
        emitsDone);
    await expectLater(
        Observable(_getStream()).transform(transformer).ignoreElements(),
        emitsDone);
  });

  test('rx.Observable.sampleTime.onDone', () async {
    final observable =
        Observable(Observable.just(1)).sampleTime(const Duration(seconds: 1));

    await expectLater(observable, emits(1));
  });

  test('rx.Observable.sampleTime.shouldClose', () async {
    final controller = StreamController<int>();

    Observable(controller.stream)
        .sampleTime(const Duration(seconds: 1)) // should trigger onDone
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.sampleTime.asBroadcastStream', () async {
    final stream = Observable(_getStream())
        .sampleTime(const Duration(milliseconds: 35))
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.sampleTime.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .sampleTime(const Duration(milliseconds: 35));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sampleTime.pause.resume', () async {
    final controller = StreamController<int>();
    StreamSubscription<int> subscription;

    subscription = Observable(_getStream())
        .sampleTime(const Duration(milliseconds: 35))
        .listen(controller.add, onDone: () {
      controller.close();
      subscription.cancel();
    });

    subscription.pause(Future<void>.delayed(const Duration(milliseconds: 50)));

    await expectLater(
        controller.stream, emitsInOrder(<dynamic>[1, 3, 4, emitsDone]));
  });
}
