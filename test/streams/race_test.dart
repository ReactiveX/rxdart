import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<num> getDelayedStream(int delay, num value) async* {
  final Completer<dynamic> completer = new Completer<dynamic>();

  new Timer(new Duration(milliseconds: delay), () => completer.complete());

  await completer.future;

  yield value;
  yield value + 1;
  yield value + 2;
}

void main() {
  test('rx.Observable.race', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);
    int expected = 1;

    new Observable<num>.race(<Stream<num>>[first, second, last])
        .listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result.compareTo(expected++), 0);
    }, count: 3));
  });

  test('rx.Observable.race.single.subscription', () async {
    final Stream<num> first = getDelayedStream(50, 1);

    Observable<num> observable = new Observable<num>.race(<Stream<num>>[first]);

    observable.listen(null);
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.race.asBroadcastStream', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);

    Stream<num> observable =
        new Observable<num>.race(<Stream<num>>[first, second, last])
            .asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.race.shouldThrowA', () {
    expect(() => new Observable<num>.race(null), throwsArgumentError);
  });

  test('rx.Observable.race.shouldThrowB', () {
    expect(
        () => new Observable<num>.race(<Stream<num>>[]), throwsArgumentError);
  });

  test('rx.Observable.race.shouldThrowC', () async {
    Stream<num> observable = new Observable<num>.race(
        <Stream<num>>[new ErrorStream<num>(new Exception('oh noes!'))]);

    // listen twice on same stream
    observable.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
  });

  test('rx.Observable.race.pause.resume', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription = new Observable<num>.race(<Stream<num>>[first, second, last])
        .listen(expectAsync1((num value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription
        .pause(new Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
