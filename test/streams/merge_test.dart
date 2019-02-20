import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

List<Stream<int>> _getStreams() {
  var a = Stream.periodic(const Duration(milliseconds: 1), (count) => count)
          .take(3),
      b = Stream.fromIterable(const [1, 2, 3, 4]);

  return [a, b];
}

void main() {
  test('rx.Observable.merge', () async {
    final observable = Observable.merge(_getStreams());

    await expectLater(
        observable, emitsInOrder(const <int>[1, 2, 3, 4, 0, 1, 2]));
  });

  test('rx.Observable.merge.single.subscription', () async {
    final observable = Observable.merge(_getStreams());

    observable.listen(null);
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.merge.asBroadcastStream', () async {
    final observable = Observable.merge(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.merge.error.shouldThrowA', () async {
    final observableWithError =
        Observable.merge(_getStreams()..add(ErrorStream<int>(Exception())));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.merge.error.shouldThrowB', () {
    expect(() => Observable<int>.merge(null), throwsArgumentError);
  });

  test('rx.Observable.merge.error.shouldThrowC', () {
    expect(() => Observable<int>.merge(const []), throwsArgumentError);
  });

  test('rx.Observable.merge.error.shouldThrowD', () {
    expect(() => Observable.merge([Observable.just(1), null]),
        throwsArgumentError);
  });

  test('rx.Observable.merge.pause.resume', () async {
    final first = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [1, 2, 3, 4][index]),
        second = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [5, 6, 7, 8][index]),
        last = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [9, 10, 11, 12][index]);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription =
        Observable.merge([first, second, last]).listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
