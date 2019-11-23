import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.dematerialize.happyPath', () async {
    const expectedValue = 1;
    final stream = Stream.value(1).materialize();

    stream.dematerialize().listen(expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('Rx.dematerialize.reusable', () async {
    final transformer = DematerializeStreamTransformer<int>();
    const expectedValue = 1;
    final streamA = Stream.value(1).materialize();
    final streamB = Stream.value(1).materialize();

    streamA.transform(transformer).listen(expectAsync1((value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));

    streamB.transform(transformer).listen(expectAsync1((value) {
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
