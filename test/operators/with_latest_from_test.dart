import '../test_utils.dart';
import 'dart:async';

import 'package:rxdart/src/observable/stream.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 22), (int count) => count);

Stream<int> _getLatestFromStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 50), (int count) => count);

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

    rx
        .observable(_getStream())
        .withLatestFrom(_getLatestFromStream(),
            (int first, int second) => new Pair(first, second))
        .take(5)
        .listen(expectAsync1((Pair result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.withLatestFrom.asBroadcastStream', () async {
    Stream<int> observable = rx
        .observable(_getStream().asBroadcastStream())
        .withLatestFrom(_getLatestFromStream().asBroadcastStream(),
            (int first, int second) => 0);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});

    expect(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.withLatestFrom.error.shouldThrow', () async {
    Stream<String> observableWithError = rx
        .observable(getErroneousStream())
        .withLatestFrom(
            _getLatestFromStream(), (num first, int second) => "Hello");

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
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
