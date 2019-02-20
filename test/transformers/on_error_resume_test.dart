import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => Stream.fromIterable(const [0, 1, 2, 3]);

const List<int> expected = [0, 1, 2, 3];

void main() {
  test('rx.Observable.onErrorResumeNext', () async {
    var count = 0;

    Observable(ErrorStream<int>(Exception()))
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResume', () async {
    var count = 0;

    Observable(ErrorStream<int>(Exception()))
        .onErrorResume((dynamic e) => _getStream())
        .listen(expectAsync1((result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResume.correctError', () async {
    final exception = Exception();

    expect(
      Observable(ErrorStream<Object>(exception))
          .onErrorResume((Object e) => Observable.just(e)),
      emits(exception),
    );
  });

  test('rx.Observable.onErrorResumeNext.asBroadcastStream', () async {
    final stream = Observable(ErrorStream<int>(Exception()))
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
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .onErrorResumeNext(ErrorStream<void>(Exception()));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.onErrorResumeNext.pause.resume', () async {
    final transformer =
        OnErrorResumeStreamTransformer<int>((Object _) => _getStream());
    final exp = const [50] + expected;
    StreamSubscription<num> subscription;
    var count = 0;

    subscription = Observable.merge([
      Observable.just(50),
      ErrorStream<int>(Exception()),
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

    Observable(ErrorStream<int>(Exception()))
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
      Observable<int>.empty().onErrorResumeNext(_getStream()),
      emitsDone,
    );
  });

  test('OnErrorResumeStreamTransformer.reusable', () async {
    final transformer = OnErrorResumeStreamTransformer<int>(
        (Object _) => _getStream().asBroadcastStream());
    var countA = 0, countB = 0;

    Observable(ErrorStream<int>(Exception()))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expected[countA++]);
        }, count: expected.length));

    Observable(ErrorStream<int>(Exception()))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expected[countB++]);
        }, count: expected.length));
  });
}
