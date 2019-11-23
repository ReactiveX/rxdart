import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    Stream<int>.periodic(const Duration(milliseconds: 20), (count) => count)
        .take(5);

Stream<int> _getSampleStream() =>
    Stream<int>.periodic(const Duration(milliseconds: 35), (count) => count)
        .take(10);

void main() {
  test('rx.Observable.sample', () async {
    final observable = _getStream().sample(_getSampleStream());

    await expectLater(observable, emitsInOrder(<dynamic>[1, 3, 4, emitsDone]));
  });

  test('rx.Observable.sample.reusable', () async {
    final transformer = SampleStreamTransformer<int>(
        (_) => _getSampleStream().asBroadcastStream());
    final observableA = _getStream().transform(transformer);
    final observableB = _getStream().transform(transformer);

    await expectLater(observableA, emitsInOrder(<dynamic>[1, 3, 4, emitsDone]));
    await expectLater(observableB, emitsInOrder(<dynamic>[1, 3, 4, emitsDone]));
  });

  test('rx.Observable.sample.onDone', () async {
    final observable = Stream.value(1).sample(Stream<void>.empty());

    await expectLater(observable, emits(1));
  });

  test('rx.Observable.sample.shouldClose', () async {
    final controller = StreamController<int>();

    controller.stream
        .sample(Stream<void>.empty()) // should trigger onDone
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    final stream = _getStream()
        .asBroadcastStream()
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.sample.error.shouldThrowA', () async {
    final observableWithError =
        Stream<void>.error(Exception()).sample(_getSampleStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.error.shouldThrowB', () async {
    final observableWithError = Stream.value(1)
        .sample(Stream<void>.error(Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.pause.resume', () async {
    final controller = StreamController<int>();
    StreamSubscription<int> subscription;

    subscription = _getStream()
        .sample(_getSampleStream())
        .listen(controller.add, onDone: () {
      controller.close();
      subscription.cancel();
    });

    await expectLater(
        controller.stream, emitsInOrder(<dynamic>[1, 3, 4, emitsDone]));

    subscription.pause();
    subscription.resume();
  });
}
