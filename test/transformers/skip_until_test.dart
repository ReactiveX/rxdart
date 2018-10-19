import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> _getOtherStream() {
  final controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 250), () {
    controller.add(1);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.skipUntil', () async {
    const expectedOutput = [3, 4];
    var count = 0;

    new Observable(_getStream())
        .skipUntil(_getOtherStream())
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.skipUntil.shouldClose', () async {
    new Observable(_getStream())
        .skipUntil(new Stream<void>.empty())
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));
  });

  test('rx.Observable.skipUntil.reusable', () async {
    final transformer = new SkipUntilStreamTransformer<int, int>(
        _getOtherStream().asBroadcastStream());
    const expectedOutput = [3, 4];
    var countA = 0, countB = 0;

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.skipUntil.asBroadcastStream', () async {
    final stream = new Observable(_getStream().asBroadcastStream())
        .skipUntil(_getOtherStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.skipUntil.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .skipUntil(_getOtherStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.skipUntil.error.shouldThrowB', () async {
    final observableWithError = new Observable.just(1)
        .skipUntil(new ErrorStream<void>(new Exception('Oh noes!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.skipUntil.error.shouldThrowC', () {
    expect(() => new Observable.just(1).skipUntil<void>(null),
        throwsArgumentError);
  });

  test('rx.Observable.skipUntil.pause.resume', () async {
    StreamSubscription<int> subscription;
    const expectedOutput = [3, 4];
    var count = 0;

    subscription = new Observable(_getStream())
        .skipUntil(_getOtherStream())
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
