import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.fromCallable', () async {
    final callable = () => 1;
    final observable = Observable.fromCallable(callable);

    await expectLater(
      observable,
      emitsInOrder(<dynamic>[1, emitsDone]),
    );
  });

  test('rx.Observable.fromCallable.asFuture', () async {
    final callable = () => Future.value(1);
    final observable = Observable.fromCallable(callable);

    await expectLater(
      observable,
      emitsInOrder(<dynamic>[1, emitsDone]),
    );
  });

  test('rx.Observable.fromCallable.multiple.listeners', () async {
    var stepper = 1;
    final callable = () => stepper++;
    final observable = Observable.fromCallable(callable);

    await expectLater(
      observable,
      emitsInOrder(<dynamic>[1, emitsDone]),
    );

    await expectLater(
      observable,
      emitsInOrder(<dynamic>[2, emitsDone]),
    );
  });

  test('rx.Observable.fromCallable.future.multiple.listeners', () async {
    var stepper = 1;
    final callable = () => Future.value(stepper++);
    final observable = Observable.fromCallable(callable);

    await expectLater(
      observable,
      emitsInOrder(<dynamic>[1, emitsDone]),
    );

    await expectLater(
      observable,
      emitsInOrder(<dynamic>[2, emitsDone]),
    );
  });

  test('rx.Observable.fromCallable.error.shouldThrow', () async {
    final callable = () {
      throw Exception();
    };
    final observableWithError = Observable.fromCallable(callable);

    await expectLater(
      observableWithError,
      emitsInOrder(<dynamic>[emitsError(isException), emitsDone]),
    );
  });

  test('rx.Observable.fromCallable.error.future.shouldThrow', () async {
    final callable = () => Future<void>.error(Exception());
    final observableWithError = Observable.fromCallable(callable);

    await expectLater(
      observableWithError,
      emitsInOrder(<dynamic>[emitsError(isException), emitsDone]),
    );
  });
}
