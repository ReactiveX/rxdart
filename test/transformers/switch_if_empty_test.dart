import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.switchIfEmpty.whenEmpty', () async {
    new Observable<bool>(new Stream<bool>.empty())
        .switchIfEmpty(new Observable<bool>.just(true))
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.reusable', () async {
    final SwitchIfEmptyStreamTransformer<bool> transformer =
        new SwitchIfEmptyStreamTransformer<bool>(
            new Observable<bool>.just(true).asBroadcastStream());

    new Observable<bool>(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));

    new Observable<bool>(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.whenNotEmpty', () async {
    new Observable<bool>.just(false)
        .switchIfEmpty(new Observable<bool>.just(true))
        .listen(expectAsync1((bool result) {
          expect(result, false);
        }, count: 1));
  });

  test('rx.Observable.switchIfEmpty.asBroadcastStream', () async {
    Observable<int> stream = new Observable<int>(new Stream<int>.empty())
        .switchIfEmpty(new Observable<int>.just(1))
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});

    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .switchIfEmpty(new Observable<int>.just(1));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrowB', () {
    expect(() => new Observable<num>.empty().switchIfEmpty(null),
        throwsArgumentError);
  });

  test('rx.Observable.switchIfEmpty.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = new Observable<int>(new Stream<int>.empty())
        .switchIfEmpty(new Observable<int>.just(1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
