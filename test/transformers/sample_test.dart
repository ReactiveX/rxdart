import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    new Stream<int>.periodic(const Duration(milliseconds: 20), (count) => count)
        .take(5);

Stream<int> _getSampleStream() =>
    new Stream<int>.periodic(const Duration(milliseconds: 35), (count) => count)
        .take(10);

void main() {
  test('rx.Observable.sample', () async {
    final observable = new Observable(_getStream()).sample(_getSampleStream());

    await expectLater(observable, emitsInOrder(const <int>[0, 2, 4]));
  });

  test('rx.Observable.sample.reusable', () async {
    final transformer = new SampleStreamTransformer<int>(
        _getSampleStream().asBroadcastStream());
    final observableA = new Observable(_getStream()).transform(transformer);
    final observableB = new Observable(_getStream()).transform(transformer);

    await Future.wait<dynamic>([
      expectLater(observableA, emitsInOrder(const <int>[0, 2, 4])),
      expectLater(observableB, emitsInOrder(const <int>[0, 2, 4]))
    ]);
  });

  test('rx.Observable.sample.onDone', () async {
    final observable = new Observable(new Observable.just(1))
        .sample(new Observable<void>.empty());

    await expectLater(observable, emits(1));
  });

  test('rx.Observable.sample.shouldClose', () async {
    final controller = new StreamController<int>();

    new Observable(controller.stream)
        .sample(new Stream<void>.empty()) // should trigger onDone
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    final stream = new Observable(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.sample.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception()))
            .sample(_getSampleStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.error.shouldThrowB', () async {
    final observableWithError = new Observable.just(1)
        .sample(new ErrorStream<void>(new Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.pause.resume', () async {
    const expectedOutput = [0, 2, 4];
    var count = 0;
    StreamSubscription<int> subscription;

    subscription = new Observable(_getStream())
        .sample(_getSampleStream())
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
