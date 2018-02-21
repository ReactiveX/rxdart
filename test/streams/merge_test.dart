import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

List<Stream<num>> _getStreams() {
  Stream<num> a = new Stream<num>.periodic(
      const Duration(milliseconds: 1), (num count) => count).take(3);
  Stream<num> b = new Stream<num>.fromIterable(const <num>[1, 2, 3, 4]);

  return <Stream<num>>[a, b];
}

void main() {
  test('rx.Observable.merge', () async {
    Stream<num> observable = new Observable<num>.merge(_getStreams());

    await expect(observable, emitsInOrder(<num>[1, 2, 3, 4, 0, 1, 2]));
  });

  test('rx.Observable.merge.single.subscription', () async {
    Stream<num> observable = new Observable<num>.merge(_getStreams());

    observable.listen((_) {});
    await expect(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.merge.asBroadcastStream', () async {
    Stream<num> observable =
        new Observable<num>.merge(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    await expect(observable.isBroadcast, isTrue);
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
}
