import 'dart:async';

import 'package:rxdart/src/streams/error.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('ErrorStream', () async {
    Stream<int> stream = new ErrorStream<int>(new Exception());

    await expect(
        stream,
        emitsInOrder(<Matcher>[
          neverEmits(anything),
          emitsError(isException),
          emitsDone
        ]));
  });

  test('ErrorStream.single.subscription', () async {
    Stream<int> stream = new ErrorStream<int>(new Exception());

    stream.listen((_) {}, onError: (dynamic e, dynamic s) {});
    await expect(
        () => stream.listen((_) {}, onError: (dynamic e, dynamic s) {}),
        throwsA(isStateError));
  });

  test('rx.Observable.error', () async {
    Observable<int> observable = new Observable<int>.error(new Exception());

    await expect(
        observable,
        emitsInOrder(<Matcher>[
          neverEmits(anything),
          emitsError(isException),
          emitsDone
        ]));
  });
}
