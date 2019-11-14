import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _observable() =>
    Observable.periodic(const Duration(milliseconds: 100), (i) => i + 1)
        .take(10);

void main() {
  test('rx.Observable.throttleTime', () async {
    await expectLater(
        _observable().throttleTime(const Duration(milliseconds: 250)).take(3),
        emitsInOrder(<dynamic>[1, 4, 7, emitsDone]));
  });

  test('rx.Observable.throttleTime.trailing', () async {
    await expectLater(
        _observable()
            .throttleTime(const Duration(milliseconds: 250), trailing: true)
            .take(3),
        emitsInOrder(<dynamic>[3, 6, 9, emitsDone]));
  });

  test('rx.Observable.throttleTime.reusable', () async {
    final transformer = ThrottleStreamTransformer<int>(
        (_) => Stream<void>.periodic(const Duration(milliseconds: 250)));

    await expectLater(_observable().transform(transformer).take(2),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));

    await expectLater(_observable().transform(transformer).take(2),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));
  });

  test('rx.Observable.throttleTime.asBroadcastStream', () async {
    final stream = _observable()
        .asBroadcastStream()
        .throttleTime(const Duration(milliseconds: 250))
        .ignoreElements();

    // listen twice on same stream
    await expectLater(stream, emitsDone);
    await expectLater(stream, emitsDone);
  });

  test('rx.Observable.throttleTime.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .throttleTime(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.throttleTime.error.shouldThrowB', () {
    expect(() => Observable.just(1).throttleTime(null),
        throwsA(const TypeMatcher<AssertionError>()));
  }, skip: true);

  test('rx.Observable.throttleTime.pause.resume', () async {
    StreamSubscription<int> subscription;

    final controller = StreamController<int>();

    subscription = _observable()
        .throttleTime(const Duration(milliseconds: 250))
        .take(2)
        .listen(controller.add, onDone: () {
      controller.close();
      subscription.cancel();
    });

    await expectLater(
        controller.stream, emitsInOrder(<dynamic>[1, 4, emitsDone]));

    await Future<Null>.delayed(const Duration(milliseconds: 150)).whenComplete(
        () => subscription
            .pause(Future<Null>.delayed(const Duration(milliseconds: 150))));
  });
}
