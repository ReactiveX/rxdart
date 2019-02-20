import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 100), () => controller.add(1));
  Timer(const Duration(milliseconds: 200), () => controller.add(2));
  Timer(const Duration(milliseconds: 300), () => controller.add(3));
  Timer(const Duration(milliseconds: 400), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> _getOtherStream() {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 250), () {
    controller.add(1);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.takeUntil', () async {
    const expectedOutput = [1, 2];
    var count = 0;

    Observable(_getStream())
        .takeUntil(_getOtherStream())
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.takeUntil.shouldClose', () async {
    Observable(_getStream())
        .takeUntil(Stream<void>.empty())
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));
  });

  test('rx.Observable.takeUntil.reusable', () async {
    final transformer = TakeUntilStreamTransformer<int, int>(
        _getOtherStream().asBroadcastStream());
    const expectedOutput = [1, 2];
    var countA = 0, countB = 0;

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.takeUntil.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream())
        .takeUntil(_getOtherStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.takeUntil.error.shouldThrowA', () async {
    final observableWithError =
        Observable(ErrorStream<void>(Exception())).takeUntil(_getOtherStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.takeUntil.error.shouldThrowB', () {
    expect(() => Observable.just(1).takeUntil<void>(null), throwsArgumentError);
  });

  test('rx.Observable.takeUntil.pause.resume', () async {
    StreamSubscription<int> subscription;
    const expectedOutput = [1, 2];
    var count = 0;

    subscription = Observable(_getStream())
        .takeUntil(_getOtherStream())
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
