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
    final observable = Observable(_getStream()).sample(_getSampleStream());

    await expectLater(observable, emitsInOrder(const <int>[0, 2, 4]));
  });

  test('rx.Observable.sample.reusable', () async {
    final transformer =
        SampleStreamTransformer<int>(_getSampleStream().asBroadcastStream());
    final observableA = Observable(_getStream()).transform(transformer);
    final observableB = Observable(_getStream()).transform(transformer);

    await Future.wait<dynamic>([
      expectLater(observableA, emitsInOrder(const <int>[0, 2, 4])),
      expectLater(observableB, emitsInOrder(const <int>[0, 2, 4]))
    ]);
  });

  test('rx.Observable.sample.onDone', () async {
    final observable =
        Observable(Observable.just(1)).sample(Observable<void>.empty());

    await expectLater(observable, emits(1));
  });

  test('rx.Observable.sample.shouldClose', () async {
    final controller = StreamController<int>();

    Observable(controller.stream)
        .sample(Stream<void>.empty()) // should trigger onDone
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.sample.error.shouldThrowA', () async {
    final observableWithError =
        Observable(ErrorStream<void>(Exception())).sample(_getSampleStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.error.shouldThrowB', () async {
    final observableWithError = Observable.just(1)
        .sample(ErrorStream<void>(Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.pause.resume', () async {
    const expectedOutput = [0, 2, 4];
    var count = 0;
    StreamSubscription<int> subscription;

    subscription = Observable(_getStream())
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
