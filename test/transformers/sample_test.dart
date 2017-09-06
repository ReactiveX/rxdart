import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 40), (int count) => count).take(5);
Stream<int> _getSampleStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 75), (int count) => count).take(10);

void main() {
  test('rx.Observable.sample', () async {
    final Observable<int> observable =
        new Observable<int>(_getStream()).sample(_getSampleStream());

    await expect(observable, emitsInOrder(const <int>[0, 2, 4]));
  });

  test('rx.Observable.sample.reusable', () async {
    final SampleStreamTransformer<int> transformer =
        new SampleStreamTransformer<int>(
            _getSampleStream().asBroadcastStream());
    final Observable<int> observableA =
        new Observable<int>(_getStream()).transform(transformer);
    final Observable<int> observableB =
        new Observable<int>(_getStream()).transform(transformer);

    await expect(observableA, emitsInOrder(const <int>[0, 2, 4]));
    await expect(observableB, emitsInOrder(const <int>[0, 2, 4]));
  });

  test('rx.Observable.sample.onDone', () async {
    Observable<int> observable =
        new Observable<int>(new Observable<int>.just(1))
            .sample(new Observable<int>.empty());

    await expect(observable, emits(1));
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(true, true);
  });

  test('rx.Observable.sample.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .sample(_getSampleStream());

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.sample.error.shouldThrowB', () async {
    Stream<num> observableWithError = new Observable<num>.just(1)
        .sample(new ErrorStream<num>(new Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
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
