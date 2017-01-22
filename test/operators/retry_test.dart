import 'dart:async';

import 'package:rxdart/src/operators/retry.dart';
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
  test('rx.Observable.retry', () async {
    observable(_getStream()).retry(3).listen(expectAsync1((int result) {
          expect(result, 3);
        }, count: 1));
  });

  test('rx.Observable.retry.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream()).retry(3);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.retry.error.shouldThrow', () async {
    Stream<int> observableWithError = observable(_getStream()).retry(2);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e is RetryError, isTrue);
    });
  });

  test('rx.Observable.retry.pause.resume', () async {
    StreamSubscription<int> subscription;
    subscription =
        observable(_getStream()).retry(3).listen(expectAsync1((int result) {
              expect(result, 3);

              subscription.cancel();
            }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
