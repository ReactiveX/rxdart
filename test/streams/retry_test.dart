import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/retry.dart';
import 'package:rxdart/src/streams/utils.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.retry', () async {
    final int retries = 3;

    await expect(
        new Observable<int>.retry(_getRetryStream(retries), retries), emits(1));
  });

  test('RetryStream', () async {
    final int retries = 3;

    await expect(
        new RetryStream<int>(_getRetryStream(retries), retries), emits(1));
  });

  test('RetryStream.onDone', () async {
    final int retries = 3;

    await expect(new RetryStream<int>(_getRetryStream(retries), retries),
        emitsInOrder(<Matcher>[equals(1), emitsDone]));
  });

  test('RetryStream.infinite.retries', () async {
    await expect(new RetryStream<int>(_getRetryStream(1000)), emits(1));
  });

  test('RetryStream.emits.original.items', () async {
    final int retries = 3;

    await expect(new RetryStream<int>(_getStreamWithExtras(retries), retries),
        emitsInOrder(<int>[1, 1, 1, 2]));
  });

  test('RetryStream.asBroadcastStream', () async {
    int retries = 3;

    Stream<int> stream = new RetryStream<int>(_getRetryStream(retries), retries)
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(stream.isBroadcast, isTrue);
  });

  test('RetryStream.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new RetryStream<int>(_getRetryStream(3), 2);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e is RetryError, isTrue);
    });
  });

  test('RetryStream.pause.resume', () async {
    StreamSubscription<int> subscription;
    int retries = 3;

    subscription = new RetryStream<int>(_getRetryStream(retries), retries)
        .listen(expectAsync1((int result) {
      expect(result, 1);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}

StreamFactory<int> _getRetryStream(int failCount) {
  int count = 0;

  return () {
    if (count < failCount) {
      count++;
      return new Observable<int>.error(new Error());
    } else {
      return new Observable<int>.just(1);
    }
  };
}

StreamFactory<int> _getStreamWithExtras(int failCount) {
  int count = 0;

  return () {
    if (count < failCount) {
      count++;
      return new Observable<int>.just(1)
          .concatWith(<Stream<int>>[new Observable<int>.error(new Error())]);
    } else {
      return new Observable<int>.just(2);
    }
  };
}
