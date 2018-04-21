import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  StreamController<int> controller = new StreamController<int>();

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
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 250), () {
    controller.add(1);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.takeUntil', () async {
    const List<int> expectedOutput = const <int>[1, 2];
    int count = 0;

    new Observable<int>(_getStream())
        .takeUntil(_getOtherStream())
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.takeUntil.shouldClose', () async {
    new Observable<int>(_getStream())
        .takeUntil(new Stream<Null>.empty())
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));
  });

  test('rx.Observable.takeUntil.reusable', () async {
    final TakeUntilStreamTransformer<int, int> transformer =
        new TakeUntilStreamTransformer<int, int>(
            _getOtherStream().asBroadcastStream());
    const List<int> expectedOutput = const <int>[1, 2];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.takeUntil.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .takeUntil(_getOtherStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.takeUntil.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .takeUntil(_getOtherStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.takeUntil.error.shouldThrowB', () {
    expect(() => new Observable<num>.just(1).takeUntil<Null>(null),
        throwsArgumentError);
  });

  test('rx.Observable.takeUntil.pause.resume', () async {
    StreamSubscription<int> subscription;
    const List<int> expectedOutput = const <int>[1, 2];
    int count = 0;

    subscription = new Observable<int>(_getStream())
        .takeUntil(_getOtherStream())
        .listen(expectAsync1((int result) {
          expect(result, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
