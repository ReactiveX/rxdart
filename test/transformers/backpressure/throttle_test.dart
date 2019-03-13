import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> _observable() =>
    Observable.periodic(const Duration(milliseconds: 100), (i) => i + 1);

void main() {
  test('rx.Observable.throttle', () async {
    await expectLater(
        _observable()
            .throttle(
                (_) => Stream<void>.periodic(const Duration(milliseconds: 250)))
            .take(3),
        emitsInOrder(<dynamic>[1, 4, 7, emitsDone]));
  });

  test('rx.Observable.throttle.dynamic.window', () async {
    await expectLater(
        _observable()
            .throttle((value) => value == 1
                ? Stream<void>.periodic(const Duration(milliseconds: 10))
                : Stream<void>.periodic(const Duration(milliseconds: 250)))
            .take(3),
        emitsInOrder(<dynamic>[1, 2, 5, emitsDone]));
  });

  test('rx.Observable.throttle.reusable', () async {
    final transformer = ThrottleStreamTransformer<int>(
        (_) => Stream<void>.periodic(const Duration(milliseconds: 250)));

    await expectLater(_observable().transform(transformer).take(2),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));

    await expectLater(_observable().transform(transformer).take(2),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));
  }, skip: true);

  test('rx.Observable.throttle.asBroadcastStream', () async {
    final stream = _observable().asBroadcastStream().throttle(
        (_) => Stream<void>.periodic(const Duration(milliseconds: 250)));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  }, skip: true);

  test('rx.Observable.throttle.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .throttle(
            (_) => Stream<void>.periodic(const Duration(milliseconds: 250)));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.throttle.error.shouldThrowB', () {
    expect(() => Observable.just(1).throttle(null),
        throwsA(const TypeMatcher<AssertionError>()));
  }, skip: true);

  test('rx.Observable.throttle.pause.resume', () async {
    StreamSubscription<int> subscription;

    final controller = StreamController<int>();

    subscription = _observable()
        .throttle(
            (_) => Stream<void>.periodic(const Duration(milliseconds: 250)))
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
  }, skip: true);
}
