import 'dart:async';
import 'package:rxdart/src/observable.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 22), (int count) => count).take(7);

Stream<int> _getLatestFromStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 50), (int count) => count).take(4);

void main() {
  test('rx.Observable.withLatestFrom', () async {
    const List<Pair> expectedOutput = const <Pair>[
      const Pair(2, 0),
      const Pair(3, 0),
      const Pair(4, 1),
      const Pair(5, 1),
      const Pair(6, 2)
    ];
    int count = 0;

    new Observable<int>(_getStream())
        .withLatestFrom(_getLatestFromStream(),
            (int first, int second) => new Pair(first, second))
        .take(5)
        .listen(expectAsync1((Pair result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.withLatestFrom.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .withLatestFrom(_getLatestFromStream().asBroadcastStream(),
            (int first, int second) => 0);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);

    await expect(true, true);
  });

  test('rx.Observable.withLatestFrom.error.shouldThrow', () async {
    Stream<String> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .withLatestFrom(
                _getLatestFromStream(), (num first, int second) => "Hello");

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.withLatestFrom.pause.resume', () async {
    StreamSubscription<Pair> subscription;
    const List<Pair> expectedOutput = const <Pair>[const Pair(2, 0)];
    int count = 0;

    subscription = new Observable<int>(_getStream())
        .withLatestFrom(_getLatestFromStream(),
            (int first, int second) => new Pair(first, second))
        .take(1)
        .listen(expectAsync1((Pair result) {
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
