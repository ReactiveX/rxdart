import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.switchIfEmpty.whenEmpty', () async {
    new Observable(new Stream<bool>.empty())
        .switchIfEmpty(new Observable.just(true))
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.reusable', () async {
    final transformer = new SwitchIfEmptyStreamTransformer<bool>(
        new Observable.just(true).asBroadcastStream());

    new Observable(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));

    new Observable(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.whenNotEmpty', () async {
    new Observable.just(false)
        .switchIfEmpty(new Observable.just(true))
        .listen(expectAsync1((result) {
          expect(result, false);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.asBroadcastStream', () async {
    final stream = new Observable(new Stream<int>.empty())
        .switchIfEmpty(new Observable.just(1))
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);

    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .switchIfEmpty(new Observable.just(1));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrowB', () {
    expect(() => new Observable<void>.empty().switchIfEmpty(null),
        throwsArgumentError);
  });

  test('rx.Observable.switchIfEmpty.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream = new Observable(new Stream<int>.empty())
        .switchIfEmpty(new Observable.just(1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
