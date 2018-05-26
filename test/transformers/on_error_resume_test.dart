import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<num> _getStream() {
  return new Stream<num>.fromIterable(<num>[0, 1, 2, 3]);
}

const List<num> expected = const <num>[0, 1, 2, 3];

void main() {
  test('rx.Observable.onErrorResumeNext', () async {
    int count = 0;

    new Observable<num>(new ErrorStream<num>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((num result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResume', () async {
    int count = 0;

    new Observable<num>(new ErrorStream<num>(new Exception()))
        .onErrorResume((dynamic e) => _getStream())
        .listen(expectAsync1((num result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResume.correctError', () async {
    final Exception exception = new Exception();

    expect(
      new Observable<dynamic>(new ErrorStream<num>(exception))
          .onErrorResume((dynamic e) => new Observable<dynamic>.just(e)),
      emits(exception),
    );
  });

  test('rx.Observable.onErrorResumeNext.asBroadcastStream', () async {
    Stream<num> stream =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .onErrorResumeNext(_getStream())
            .asBroadcastStream();
    int countA = 0;
    int countB = 0;

    await expectLater(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((num result) {
      expect(result, expected[countA++]);
    }, count: expected.length));
    stream.listen(expectAsync1((num result) {
      expect(result, expected[countB++]);
    }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .onErrorResumeNext(new ErrorStream<num>(new Exception()));

    observableWithError.listen((_) {},
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.onErrorResumeNext.pause.resume', () async {
    final OnErrorResumeStreamTransformer<num> transformer =
        new OnErrorResumeStreamTransformer<num>((dynamic e) => _getStream());
    final List<num> exp = <num>[50] + expected;
    StreamSubscription<num> subscription;
    int count = 0;

    subscription = new Observable<num>.merge(<Stream<num>>[
      new Observable<num>.just(50),
      new ErrorStream<num>(new Exception()),
    ]).transform(transformer).listen(expectAsync1((num result) {
          expect(result, exp[count++]);

          if (count == exp.length) {
            subscription.cancel();
          }
        }, count: exp.length));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.onErrorResumeNext.close', () async {
    int count = 0;

    new Observable<num>(new ErrorStream<num>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(
            expectAsync1((num result) {
              expect(result, expected[count++]);
            }, count: expected.length),
            onDone: expectAsync0(() {
              // The code should reach this point
              expect(true, true);
            }, count: 1));
  });

  test('rx.Observable.onErrorResumeNext.noErrors.close', () async {
    expect(
      new Observable<num>.empty().onErrorResumeNext(_getStream()),
      emitsDone,
    );
  });

  test('OnErrorResumeStreamTransformer.reusable', () async {
    final OnErrorResumeStreamTransformer<num> transformer =
        new OnErrorResumeStreamTransformer<num>(
            (dynamic e) => _getStream().asBroadcastStream());
    int countA = 0, countB = 0;

    new Observable<num>(new ErrorStream<num>(new Exception()))
        .transform(transformer)
        .listen(expectAsync1((num result) {
          expect(result, expected[countA++]);
        }, count: expected.length));

    new Observable<num>(new ErrorStream<num>(new Exception()))
        .transform(transformer)
        .listen(expectAsync1((num result) {
          expect(result, expected[countB++]);
        }, count: expected.length));
  });
}
