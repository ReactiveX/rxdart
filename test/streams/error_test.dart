import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/error.dart';
import 'package:test/test.dart';

void main() {
  test('ErrorStream', () async {
    Stream<int> stream = ErrorStream<int>(Exception());

    await expectLater(
        stream,
        emitsInOrder(<Matcher>[
          neverEmits(anything),
          emitsError(isException),
          emitsDone
        ]));
  });

  test('ErrorStream.single.subscription', () async {
    Stream<int> stream = ErrorStream<int>(Exception());

    // expect to hit onError in first subscription
    // expect immediate error when trying another subscription
    stream.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
    await expectLater(() => stream.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.error', () async {
    final observable = Observable<int>.error(Exception());

    await expectLater(
        observable,
        emitsInOrder(<Matcher>[
          neverEmits(anything),
          emitsError(isException),
          emitsDone
        ]));
  });
}
