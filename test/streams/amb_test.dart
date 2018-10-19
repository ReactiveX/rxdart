import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<num> getDelayedStream(int delay, num value) async* {
  final completer = new Completer<dynamic>();

  new Timer(new Duration(milliseconds: delay), () => completer.complete());

  await completer.future;

  yield value;
  yield value + 1;
  yield value + 2;
}

void main() {
  test('rx.Observable.amb', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);
    var expected = 1;

    // ignore: deprecated_member_use
    new Observable.amb([first, second, last]).listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result.compareTo(expected++), 0);
    }, count: 3));
  });

  test('rx.Observable.amb.single.subscription', () async {
    final first = getDelayedStream(50, 1);

    // ignore: deprecated_member_use
    final observable = new Observable.amb([first]);

    observable.listen(null);
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.amb.asBroadcastStream', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);

    final observable =
        // ignore: deprecated_member_use
        new Observable.amb([first, second, last]).asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.amb.shouldThrowA', () {
    // ignore: deprecated_member_use
    expect(() => new Observable<num>.amb(null), throwsArgumentError);
  });

  test('rx.Observable.amb.shouldThrowB', () {
    // ignore: deprecated_member_use
    expect(() => new Observable<num>.amb(<Stream<num>>[]), throwsArgumentError);
  });

  test('rx.Observable.amb.shouldThrowC', () async {
    var observable =
        // ignore: deprecated_member_use
        new Observable<num>.amb([new ErrorStream(new Exception('oh noes!'))]);

    // listen twice on same stream
    observable.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
  });

  test('rx.Observable.amb.pause.resume', () async {
    final first = getDelayedStream(50, 1),
        second = getDelayedStream(60, 2),
        last = getDelayedStream(70, 3);

    StreamSubscription<num> subscription;

    subscription =
        // ignore: deprecated_member_use
        new Observable.amb([first, second, last]).listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription
        .pause(new Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
