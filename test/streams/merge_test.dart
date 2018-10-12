import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

List<Stream<num>> _getStreams() {
  Stream<num> a = new Stream<num>.periodic(
      const Duration(milliseconds: 1), (num count) => count).take(3);
  Stream<num> b = new Stream<num>.fromIterable(const <num>[1, 2, 3, 4]);

  return <Stream<num>>[a, b];
}

void main() {
  test('rx.Observable.merge', () async {
    Stream<num> observable = new Observable<num>.merge(_getStreams());

    await expectLater(observable, emitsInOrder(<num>[1, 2, 3, 4, 0, 1, 2]));
  });

  test('rx.Observable.merge.single.subscription', () async {
    Stream<num> observable = new Observable<num>.merge(_getStreams());

    observable.listen((_) {});
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.merge.asBroadcastStream', () async {
    Stream<num> observable =
        new Observable<num>.merge(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.merge.error.shouldThrowA', () async {
    Stream<num> observableWithError = new Observable<num>.merge(
        _getStreams()..add(new ErrorStream<num>(new Exception())));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.merge.error.shouldThrowB', () {
    expect(() => new Observable<num>.merge(null), throwsArgumentError);
  });

  test('rx.Observable.merge.error.shouldThrowC', () {
    expect(
        () => new Observable<num>.merge(<Stream<num>>[]), throwsArgumentError);
  });

  test('rx.Observable.merge.error.shouldThrowD', () {
    expect(
        () => new Observable<num>.merge(
            <Stream<num>>[new Observable<num>.just(1), null]),
        throwsArgumentError);
  });

  test('rx.Observable.merge.pause.resume', () async {
    final Stream<num> first = new Stream<num>.periodic(
        const Duration(milliseconds: 10),
        (int index) => const <num>[1, 2, 3, 4][index]);
    final Stream<num> second = new Stream<num>.periodic(
        const Duration(milliseconds: 10),
        (int index) => const <num>[5, 6, 7, 8][index]);
    final Stream<num> last = new Stream<num>.periodic(
        const Duration(milliseconds: 10),
        (int index) => const <num>[9, 10, 11, 12][index]);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription = new Observable<num>.merge(<Stream<num>>[first, second, last])
        .listen(expectAsync1((num value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription
        .pause(new Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
