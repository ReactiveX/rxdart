import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.sequenceEqual.equals', () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 2, 3, 4, 5]),
        Stream.fromIterable(const [1, 2, 3, 4, 5]));

    await expectLater(observable, emitsInOrder(<dynamic>[true, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.diffTime.equals', () async {
    final observable = Observable.sequenceEqual(
        Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
            .take(5),
        Stream.fromIterable(const [1, 2, 3, 4, 5]));

    await expectLater(observable, emitsInOrder(<dynamic>[true, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.equals.customCompare.equals', () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 1, 1, 1, 1]),
        Stream.fromIterable(const [2, 2, 2, 2, 2]),
        equals: (int a, int b) => true);

    await expectLater(observable, emitsInOrder(<dynamic>[true, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.diffTime.notEquals', () async {
    final observable = Observable.sequenceEqual(
        Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
            .take(5),
        Stream.fromIterable(const [1, 1, 1, 1, 1]));

    await expectLater(observable, emitsInOrder(<dynamic>[false, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.notEquals', () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 2, 3, 4, 5]),
        Stream.fromIterable(const [1, 2, 3, 5, 4]));

    await expectLater(observable, emitsInOrder(<dynamic>[false, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.equals.customCompare.notEquals', () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 1, 1, 1, 1]),
        Stream.fromIterable(const [1, 1, 1, 1, 1]),
        equals: (int a, int b) => false);

    await expectLater(observable, emitsInOrder(<dynamic>[false, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.notEquals.differentLength', () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 2, 3, 4, 5]),
        Stream.fromIterable(const [1, 2, 3, 4, 5, 6]));

    await expectLater(observable, emitsInOrder(<dynamic>[false, emitsDone]));
  });

  test(
      'rx.Observable.sequenceEqual.notEquals.differentLength.customCompare.notEquals',
      () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 2, 3, 4, 5]),
        Stream.fromIterable(const [1, 2, 3, 4, 5, 6]),
        equals: (int a, int b) => true);

    // expect false,
    // even if the equals handler always returns true,
    // the emitted events length is different
    await expectLater(observable, emitsInOrder(<dynamic>[false, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.equals.errors', () async {
    final observable = Observable.sequenceEqual(
        Observable<void>.error(ArgumentError('error A')),
        Observable<void>.error(ArgumentError('error A')));

    await expectLater(observable, emitsInOrder(<dynamic>[true, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.notEquals.errors', () async {
    final observable = Observable.sequenceEqual(
        Observable<void>.error(ArgumentError('error A')),
        Observable<void>.error(ArgumentError('error B')));

    await expectLater(observable, emitsInOrder(<dynamic>[false, emitsDone]));
  });

  test('rx.Observable.sequenceEqual.single.subscription', () async {
    final observable = Observable.sequenceEqual(
        Stream.fromIterable(const [1, 2, 3, 4, 5]),
        Stream.fromIterable(const [1, 2, 3, 4, 5]));

    await expectLater(observable, emitsInOrder(<dynamic>[true, emitsDone]));
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.sequenceEqual.asBroadcastStream', () async {
    final observable = Observable.sequenceEqual(
            Stream.fromIterable(const [1, 2, 3, 4, 5]),
            Stream.fromIterable(const [1, 2, 3, 4, 5]))
        .asBroadcastStream()
        .ignoreElements();

    // listen twice on same stream
    await expectLater(observable, emitsDone);
    await expectLater(observable, emitsDone);
  });

  test('rx.Observable.sequenceEqual.error.shouldThrowA', () {
    expect(
        () => Observable.sequenceEqual<int, void>(
            Stream.fromIterable(const [1, 2, 3, 4, 5]), null),
        throwsArgumentError);
  });

  test('rx.Observable.sequenceEqual.error.shouldThrowB', () {
    expect(
        () => Observable.sequenceEqual<void, int>(
            null, Stream.fromIterable(const [1, 2, 3, 4, 5])),
        throwsArgumentError);
  });
}
