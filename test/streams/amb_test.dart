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
  test('rx.Observable.amb', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);
    int expected = 1;

    // ignore: deprecated_member_use
    new Observable<num>.amb(<Stream<num>>[first, second, last])
        .listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result.compareTo(expected++), 0);
    }, count: 3));
  });

  test('rx.Observable.amb.single.subscription', () async {
    final Stream<num> first = getDelayedStream(50, 1);

    // ignore: deprecated_member_use
    Observable<num> observable = new Observable<num>.amb(<Stream<num>>[first]);

    observable.listen(null);
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.amb.asBroadcastStream', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);

    Stream<num> observable =
        // ignore: deprecated_member_use
        new Observable<num>.amb(<Stream<num>>[first, second, last])
            .asBroadcastStream();

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
    // ignore: deprecated_member_use
    Stream<num> observable = new Observable<num>.amb(
        <Stream<num>>[new ErrorStream<num>(new Exception('oh noes!'))]);

    // listen twice on same stream
    observable.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
  });

  test('rx.Observable.amb.pause.resume', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription = new Observable<num>.amb(<Stream<num>>[first, second, last])
        .listen(expectAsync1((num value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription
        .pause(new Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
