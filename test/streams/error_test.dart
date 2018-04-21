import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/error.dart';
import 'package:test/test.dart';

void main() {
  test('ErrorStream', () async {
    Stream<int> stream = new ErrorStream<int>(new Exception());

    await expectLater(
        stream,
        emitsInOrder(<Matcher>[
          neverEmits(anything),
          emitsError(isException),
          emitsDone
        ]));
  });

  test('ErrorStream.single.subscription', () async {
    Stream<int> stream = new ErrorStream<int>(new Exception());

    // expect to hit onError in first subscription
    // expect immediate error when trying another subscription
    stream.listen(null,
        onError: expectAsync2(
            (Exception e, StackTrace s) => expect(e, isException)));
    await expectLater(() => stream.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.error', () async {
    Observable<int> observable = new Observable<int>.error(new Exception());

    await expectLater(
        observable,
        emitsInOrder(<Matcher>[
          neverEmits(anything),
          emitsError(isException),
          emitsDone
        ]));
  });
}
