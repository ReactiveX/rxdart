import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
  Stream<int> testStream =
      new Stream<int>.fromIterable(const <int>[0, 1, 2, 3]).map((int i) {
    if (i < 3) throw new Error();

    return i;
  });

  return testStream;
}

void main() {
  test('rx.Observable.retry.assertWhenSingleSubscription', () async {
    try {
      // If call contains no arguments, throw a runtime error in dev mode
      // in order to "fail fast" and alert the developer that the operator
      // can be used or safely removed.
      new Observable<int>(_getStream())
          .retry()
          .listen(null);
    } catch (e) {
      await expect(e is AssertionError, isTrue);
    }
  });


  test('rx.Observable.retry.asBroadcastStream.1', () async {
    Stream<int> stream =
        new Observable<int>(_getStream().asBroadcastStream()).retry(count: 3);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(true, true);
  });

  test('rx.Observable.retry.asBroadcastStream.2', () async {
    new Observable<int>(_getStream().asBroadcastStream())
        .retry(count: 3)
        .listen(expectAsync1((int result) {
      expect(result, 3);
    }, count: 1));
  });

  test('rx.Observable.retry.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new Observable<int>(_getStream().asBroadcastStream()).retry(count: 2);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e is RetryError, isTrue);
    });
  });

  test('rx.Observable.retry.pause.resume', () async {
    StreamSubscription<int> subscription;
    subscription = new Observable<int>(_getStream().asBroadcastStream())
        .retry(count: 3)
        .listen(expectAsync1((int result) {
          expect(result, 3);

          subscription.cancel();
        }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
