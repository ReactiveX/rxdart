import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.dematerialize.happyPath', () async {
    const expectedValue = 1;
    final observable = Observable.just(1).materialize();

    observable.dematerialize<int>().listen(expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('rx.Observable.dematerialize.reusable', () async {
    final transformer = DematerializeStreamTransformer<int>();
    const expectedValue = 1;
    final observableA = Observable.just(1).materialize();
    final observableB = Observable.just(1).materialize();

    observableA.transform(transformer).listen(expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));

    observableB.transform(transformer).listen(expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('dematerializeTransformer.happyPath', () async {
    const expectedValue = 1;
    final stream = Stream.fromIterable(
        [Notification.onData(expectedValue), Notification<int>.onDone()]);

    stream.transform(DematerializeStreamTransformer()).listen(
        expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('dematerializeTransformer.sadPath', () async {
    final stream = Stream.fromIterable(
        [Notification<int>.onError(Exception(), Chain.current())]);

    stream.transform(DematerializeStreamTransformer()).listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('dematerializeTransformer.onPause.onResume', () async {
    const expectedValue = 1;
    final stream = Stream.fromIterable(
        [Notification.onData(expectedValue), Notification<int>.onDone()]);

    stream.transform(DematerializeStreamTransformer()).listen(
        expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }))
      ..pause()
      ..resume();
  });
}
