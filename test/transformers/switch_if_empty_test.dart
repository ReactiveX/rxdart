import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.switchIfEmpty.whenEmpty', () async {
    new Observable<bool>(new Stream<bool>.empty())
        .switchIfEmpty(new Observable<bool>.just(true))
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
    expect(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.switchIfEmpty.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .switchIfEmpty(new Observable<int>.just(1));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
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
