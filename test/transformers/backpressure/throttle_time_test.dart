import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _stream() =>
    Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1).take(10);

void main() {
  test('Rx.throttleTime', () async {
    await expectLater(
        _stream().throttleTime(const Duration(milliseconds: 250)).take(3),
        emitsInOrder(<dynamic>[1, 4, 7, emitsDone]));
  });

  test('Rx.throttleTime.trailing', () async {
    await expectLater(
        _stream()
            .throttleTime(const Duration(milliseconds: 250), trailing: true)
            .take(3),
        emitsInOrder(<dynamic>[3, 6, 9, emitsDone]));
  });

  test('Rx.throttleTime.reusable', () async {
    final transformer = ThrottleStreamTransformer<int>(
        (_) => Stream<void>.periodic(const Duration(milliseconds: 250)));

    await expectLater(_stream().transform(transformer).take(2),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));

    await expectLater(_stream().transform(transformer).take(2),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));
  });

  test('Rx.throttleTime.asBroadcastStream', () async {
    final future = _stream()
        .asBroadcastStream()
        .throttleTime(const Duration(milliseconds: 250))
        .drain<void>();

    // listen twice on same stream
    await expectLater(future, completes);
    await expectLater(future, completes);
  });

  test('Rx.throttleTime.error.shouldThrowA', () async {
    final streamWithError = Stream<void>.error(Exception())
        .throttleTime(const Duration(milliseconds: 200));

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.throttleTime.error.shouldThrowB', () {
    expect(() => Stream.value(1).throttleTime(null),
        throwsA(const TypeMatcher<AssertionError>()));
  }, skip: true);

  test('Rx.throttleTime.pause.resume', () async {
    StreamSubscription<int> subscription;

    final controller = StreamController<int>();

    subscription = _stream()
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
