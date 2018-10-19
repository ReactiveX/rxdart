import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [0, 1, 2, 3]);

const List<int> expected = [0, 1, 2, 3];

void main() {
  test('rx.Observable.onErrorResumeNext', () async {
    var count = 0;

    new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResume', () async {
    var count = 0;

    new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResume((dynamic e) => _getStream())
        .listen(expectAsync1((result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResume.correctError', () async {
    final exception = new Exception();

    expect(
      new Observable(new ErrorStream<Object>(exception))
          .onErrorResume((Object e) => new Observable.just(e)),
      emits(exception),
    );
  });

  test('rx.Observable.onErrorResumeNext.asBroadcastStream', () async {
    final stream = new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResumeNext(_getStream())
        .asBroadcastStream();
    var countA = 0, countB = 0;

    await expectLater(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((result) {
      expect(result, expected[countA++]);
    }, count: expected.length));
    stream.listen(expectAsync1((result) {
      expect(result, expected[countB++]);
    }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.error.shouldThrow', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception()))
            .onErrorResumeNext(new ErrorStream<void>(new Exception()));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.onErrorResumeNext.pause.resume', () async {
    final transformer =
        new OnErrorResumeStreamTransformer<int>((Object _) => _getStream());
    final exp = const [50] + expected;
    StreamSubscription<num> subscription;
    var count = 0;

    subscription = new Observable.merge([
      new Observable.just(50),
      new ErrorStream<int>(new Exception()),
    ]).transform(transformer).listen(expectAsync1((result) {
          expect(result, exp[count++]);

          if (count == exp.length) {
            subscription.cancel();
          }
        }, count: exp.length));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.onErrorResumeNext.close', () async {
    var count = 0;

    new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(
            expectAsync1((result) {
              expect(result, expected[count++]);
            }, count: expected.length),
            onDone: expectAsync0(() {
              // The code should reach this point
              expect(true, true);
            }, count: 1));
  });

  test('rx.Observable.onErrorResumeNext.noErrors.close', () async {
    expect(
      new Observable<int>.empty().onErrorResumeNext(_getStream()),
      emitsDone,
    );
  });

  test('OnErrorResumeStreamTransformer.reusable', () async {
    final transformer = new OnErrorResumeStreamTransformer<int>(
        (Object _) => _getStream().asBroadcastStream());
    var countA = 0, countB = 0;

    new Observable(new ErrorStream<int>(new Exception()))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expected[countA++]);
        }, count: expected.length));

    new Observable(new ErrorStream<int>(new Exception()))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expected[countB++]);
        }, count: expected.length));
  });
}
