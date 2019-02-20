import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observables/observable.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    Stream.periodic(const Duration(milliseconds: 22), (count) => count).take(7);

Stream<int> _getLatestFromStream() =>
    Stream.periodic(const Duration(milliseconds: 50), (count) => count).take(4);

void main() {
  test('rx.Observable.withLatestFrom', () async {
    const expectedOutput = [
      Pair(2, 0),
      Pair(3, 0),
      Pair(4, 1),
      Pair(5, 1),
      Pair(6, 2)
    ];
    var count = 0;

    Observable(_getStream())
        .withLatestFrom(
            _getLatestFromStream(), (first, int second) => Pair(first, second))
        .take(5)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.withLatestFrom.reusable', () async {
    final transformer = WithLatestFromStreamTransformer<int, int, Pair>(
        _getLatestFromStream().asBroadcastStream(),
        (first, second) => Pair(first, second));
    const expectedOutput = [
      Pair(2, 0),
      Pair(3, 0),
      Pair(4, 1),
      Pair(5, 1),
      Pair(6, 2)
    ];
    var countA = 0, countB = 0;

    Observable(_getStream())
        .transform(transformer)
        .take(5)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length));

    Observable(_getStream())
        .transform(transformer)
        .take(5)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.withLatestFrom.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream()).withLatestFrom(
        _getLatestFromStream().asBroadcastStream(), (first, int second) => 0);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);

    await expectLater(true, true);
  });

  test('rx.Observable.withLatestFrom.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .withLatestFrom(_getLatestFromStream(), (first, int second) => "Hello");

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.withLatestFrom.error.shouldThrowB', () {
    expect(
        () => Observable.just(1)
            .withLatestFrom(null, (first, int second) => "Hello"),
        throwsArgumentError);
  });

  test('rx.Observable.withLatestFrom.error.shouldThrowC', () {
    expect(
        () => Observable(_getStream())
            .withLatestFrom<int, void>(_getLatestFromStream(), null),
        throwsArgumentError);
  });

  test('rx.Observable.withLatestFrom.pause.resume', () async {
    StreamSubscription<Pair> subscription;
    const expectedOutput = [Pair(2, 0)];
    var count = 0;

    subscription = Observable(_getStream())
        .withLatestFrom(
            _getLatestFromStream(), (first, int second) => Pair(first, second))
        .take(1)
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

class Pair {
  final int first;
  final int second;

  const Pair(this.first, this.second);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Pair &&
        this.first == other.first &&
        this.second == other.second;
  }

  @override
  int get hashCode {
    return first.hashCode ^ second.hashCode;
  }

  @override
  String toString() {
    return 'Pair{first: $first, second: $second}';
  }
}
