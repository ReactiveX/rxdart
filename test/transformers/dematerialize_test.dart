import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.dematerialize.happyPath', () async {
    final int expectedValue = 1;
    final Observable<Notification<int>> observable =
        new Observable<int>.just(1).materialize();

    observable.dematerialize<int>().listen(expectAsync1((int value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('rx.Observable.dematerialize.reusable', () async {
    final DematerializeStreamTransformer<int> transformer =
        new DematerializeStreamTransformer<int>();
    final int expectedValue = 1;
    final Observable<Notification<int>> observableA =
        new Observable<int>.just(1).materialize();
    final Observable<Notification<int>> observableB =
        new Observable<int>.just(1).materialize();

    observableA.transform(transformer).listen(expectAsync1((int value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));

    observableB.transform(transformer).listen(expectAsync1((int value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('dematerializeTransformer.happyPath', () async {
    final int expectedValue = 1;
    final Stream<Notification<int>> stream =
        new Stream<Notification<int>>.fromIterable(<Notification<int>>[
      new Notification<int>.onData(expectedValue),
      new Notification<int>.onDone()
    ]);

    stream.transform(new DematerializeStreamTransformer<int>()).listen(
        expectAsync1((int value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }));
  });

  test('dematerializeTransformer.sadPath', () async {
    final Stream<Notification<int>> stream =
        new Stream<Notification<int>>.fromIterable(<Notification<int>>[
      new Notification<int>.onError(new Exception(), new Chain.current())
    ]);

    stream.transform(new DematerializeStreamTransformer<int>()).listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('dematerializeTransformer.onPause.onResume', () async {
    final int expectedValue = 1;
    final Stream<Notification<int>> stream =
        new Stream<Notification<int>>.fromIterable(<Notification<int>>[
      new Notification<int>.onData(expectedValue),
      new Notification<int>.onDone()
    ]);

    stream.transform(new DematerializeStreamTransformer<int>()).listen(
        expectAsync1((int value) {
      expect(value, expectedValue);
    }), onDone: expectAsync0(() {
      // Should call onDone
      expect(true, isTrue);
    }))
      ..pause()
      ..resume();
  });
}
