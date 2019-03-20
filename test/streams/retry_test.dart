import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/retry.dart';
import 'package:rxdart/src/streams/utils.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.retry', () async {
    const retries = 3;

    await expectLater(Observable.retry(_getRetryStream(retries), retries),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream', () async {
    const retries = 3;

    await expectLater(RetryStream<int>(_getRetryStream(retries), retries),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream.onDone', () async {
    const retries = 3;

    await expectLater(RetryStream(_getRetryStream(retries), retries),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream.infinite.retries', () async {
    await expectLater(RetryStream(_getRetryStream(1000)),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('RetryStream.emits.original.items', () async {
    const retries = 3;

    await expectLater(RetryStream(_getStreamWithExtras(retries), retries),
        emitsInOrder(<dynamic>[1, 1, 1, 2, emitsDone]));
  });

  test('RetryStream.single.subscription', () async {
    const retries = 3;

    final stream = RetryStream(_getRetryStream(retries), retries);

    try {
      stream.listen(null);
      stream.listen(null);
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });

  test('RetryStream.asBroadcastStream', () async {
    const retries = 3;

    final stream =
        RetryStream(_getRetryStream(retries), retries).asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('RetryStream.error.shouldThrow', () async {
    final observableWithError = RetryStream(_getRetryStream(3), 2);

    await expectLater(
        observableWithError,
        emitsInOrder(
            <Matcher>[emitsError(TypeMatcher<RetryError>()), emitsDone]));
  });

  test('RetryStream.error.capturesErrors', () async {
    final observableWithError = RetryStream(_getRetryStream(3), 2);

    await expectLater(
        observableWithError,
        emitsInOrder(<Matcher>[
          emitsError(
            predicate<RetryError>((a) {
              return a.errors.length == 3 &&
                  a.errors
                      .every((es) => es.error != null && es.stacktrace != null);
            }),
          ),
          emitsDone,
        ]));
  });

  test('RetryStream.pause.resume', () async {
    StreamSubscription<int> subscription;
    const retries = 3;

    subscription = RetryStream(_getRetryStream(retries), retries)
        .listen(expectAsync1((result) {
      expect(result, 1);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}

Stream<int> Function() _getRetryStream(int failCount) {
  var count = 0;

  return () {
    if (count < failCount) {
      count++;
      return ErrorStream<int>(Error());
    } else {
      return Observable.just(1);
    }
  };
}

Stream<int> Function() _getStreamWithExtras(int failCount) {
  var count = 0;

  return () {
    if (count < failCount) {
      count++;

      // Emit first item
      return Observable.just(1)
          // Emit the error
          .concatWith([ErrorStream<int>(Error())])
          // Emit an extra item, testing that it is not included
          .concatWith([Observable.just(1)]);
    } else {
      return Observable.just(2);
    }
  };
}
