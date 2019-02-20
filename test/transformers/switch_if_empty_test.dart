import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.switchIfEmpty.whenEmpty', () async {
    expect(
      Observable<int>.empty().switchIfEmpty(Observable.just(1)),
      emitsInOrder(<dynamic>[1, emitsDone]),
    );
  });

  test('rx.Observable.initial.completes', () async {
    expect(
      Observable.just(99).switchIfEmpty(Observable.just(1)),
      emitsInOrder(<dynamic>[99, emitsDone]),
    );
  });

  test('rx.Observable.switchIfEmpty.reusable', () async {
    final transformer = SwitchIfEmptyStreamTransformer<bool>(
        Observable.just(true).asBroadcastStream());

    Observable(Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));

    Observable(Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.whenNotEmpty', () async {
    Observable.just(false)
        .switchIfEmpty(Observable.just(true))
        .listen(expectAsync1((result) {
          expect(result, false);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.asBroadcastStream', () async {
    final stream = Observable(Stream<int>.empty())
        .switchIfEmpty(Observable.just(1))
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);

    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<int>(Exception()))
        .switchIfEmpty(Observable.just(1));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrowB', () {
    expect(() => Observable<void>.empty().switchIfEmpty(null),
        throwsArgumentError);
  });

  test('rx.Observable.switchIfEmpty.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream =
        Observable(Stream<int>.empty()).switchIfEmpty(Observable.just(1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
