import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 20), (int count) => count).take(5);

Stream<int> _getSampleStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 35), (int count) => count).take(10);

void main() {
  test('rx.Observable.sample', () async {
    final Observable<int> observable =
        new Observable<int>(_getStream()).sample(_getSampleStream());

    await expectLater(observable, emitsInOrder(const <int>[0, 2, 4]));
  });

  test('rx.Observable.sample.reusable', () async {
    final SampleStreamTransformer<int> transformer =
        new SampleStreamTransformer<int>(
            _getSampleStream().asBroadcastStream());
    final Observable<int> observableA =
        new Observable<int>(_getStream()).transform(transformer);
    final Observable<int> observableB =
        new Observable<int>(_getStream()).transform(transformer);

    await Future.wait<dynamic>(<Future<dynamic>>[
      expectLater(observableA, emitsInOrder(const <int>[0, 2, 4])),
      expectLater(observableB, emitsInOrder(const <int>[0, 2, 4]))
    ]);
  });

  test('rx.Observable.sample.onDone', () async {
    Observable<int> observable =
        new Observable<int>(new Observable<int>.just(1))
            .sample(new Observable<int>.empty());

    await expectLater(observable, emits(1));
  });

  test('rx.Observable.sample.shouldClose', () async {
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .sample(new Stream<Null>.empty()) // should trigger onDone
        .listen(null, onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.sample.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .sample(_getSampleStream());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.error.shouldThrowB', () async {
    Stream<num> observableWithError = new Observable<num>.just(1)
        .sample(new ErrorStream<num>(new Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.pause.resume', () async {
    const List<int> expectedOutput = const <int>[0, 2, 4];
    int count = 0;
    StreamSubscription<int> subscription;

    subscription = new Observable<int>(_getStream())
        .sample(_getSampleStream())
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
