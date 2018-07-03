import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/retry.dart';
import 'package:rxdart/src/streams/utils.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.retry', () async {
    final int retries = 3;

    await expectLater(
        new Observable<int>.retry(_getRetryStream(retries), retries),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream', () async {
    final int retries = 3;

    await expectLater(new RetryStream<int>(_getRetryStream(retries), retries),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream.onDone', () async {
    final int retries = 3;

    await expectLater(new RetryStream<int>(_getRetryStream(retries), retries),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream.infinite.retries', () async {
    await expectLater(new RetryStream<int>(_getRetryStream(1000)),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream.emits.original.items', () async {
    final int retries = 3;

    await expectLater(
        new RetryStream<int>(_getStreamWithExtras(retries), retries),
        emitsInOrder(<dynamic>[1, 1, 1, 2, emitsDone]));
  });

  test('RetryStream.single.subscription', () async {
    int retries = 3;

    Stream<int> stream =
        new RetryStream<int>(_getRetryStream(retries), retries);

    try {
      stream.listen((_) {});
      stream.listen((_) {});
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });

  test('RetryStream.asBroadcastStream', () async {
    int retries = 3;

    Stream<int> stream = new RetryStream<int>(_getRetryStream(retries), retries)
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('RetryStream.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new RetryStream<int>(_getRetryStream(3), 2);

    await expectLater(
        observableWithError,
        emitsInOrder(
            <Matcher>[emitsError(new TypeMatcher<RetryError>()), emitsDone]));
  });

  test('RetryStream.error.capturesErrors', () async {
    Stream<int> observableWithError =
        new RetryStream<int>(_getRetryStream(3), 2);

    await expectLater(
        observableWithError,
        emitsInOrder(<Matcher>[
          emitsError(
            predicate<RetryError>((RetryError a) {
              return a.errors.length == 3 &&
                  a.errors.every((ErrorAndStacktrace es) =>
                      es.error != null && es.stacktrace != null);
            }),
          ),
          emitsDone,
        ]));
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
      return new ErrorStream<int>(new Error());
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

      // Emit first item
      return new Observable<int>.just(1)
          // Emit the error
          .concatWith(<Stream<int>>[new ErrorStream<int>(new Error())])
          // Emit an extra item, testing that it is not included
          .concatWith(<Stream<int>>[new Observable<int>.just(1)]);
    } else {
      return new Observable<int>.just(2);
    }
  };
}
