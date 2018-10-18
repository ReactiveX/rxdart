import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> getDelayedStream(int delay, int value) async* {
  final completer = new Completer<Null>();

  new Timer(new Duration(milliseconds: delay), () => completer.complete());

  await completer.future;

  yield value;
  yield value + 1;
  yield value + 2;
}

void main() {
  test('rx.Observable.race', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);
    var expected = 1;

    new Observable.race([first, second, last]).listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result.compareTo(expected++), 0);
    }, count: 3));
  });

  test('rx.Observable.race.single.subscription', () async {
    final first = getDelayedStream(50, 1);

    final observable = new Observable.race([first]);

    observable.listen(null);
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.race.asBroadcastStream', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);

    final observable =
        new Observable.race([first, second, last]).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.race.shouldThrowA', () {
    expect(() => new Observable<Null>.race(null), throwsArgumentError);
  });

  test('rx.Observable.race.shouldThrowB', () {
    expect(() => new Observable<Null>.race(const []), throwsArgumentError);
  });

  test('rx.Observable.race.shouldThrowC', () async {
    final observable =
        new Observable.race([new ErrorStream<Null>(new Exception('oh noes!'))]);

    // listen twice on same stream
    observable.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
  });

  test('rx.Observable.race.pause.resume', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);

    StreamSubscription<int> subscription;
    // ignore: deprecated_member_use
    subscription =
        new Observable.race([first, second, last]).listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription
        .pause(new Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
