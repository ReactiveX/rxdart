import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  test('Rx.materialize.happyPath', () async {
    final stream = Stream.value(1);
    final notifications = <RxNotification<int>>[];

    stream.materialize().listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications,
          [RxNotification.onData(1), RxNotification<int>.onDone()]);
    }));
  });

  test('Rx.materialize.reusable', () async {
    final transformer = MaterializeStreamTransformer<int>();
    final stream = Stream.value(1).asBroadcastStream();
    final notificationsA = <RxNotification<int>>[],
        notificationsB = <RxNotification<int>>[];

    stream.transform(transformer).listen(notificationsA.add,
        onDone: expectAsync0(() {
      expect(notificationsA,
          [RxNotification.onData(1), RxNotification<int>.onDone()]);
    }));

    stream.transform(transformer).listen(notificationsB.add,
        onDone: expectAsync0(() {
      expect(notificationsB,
          [RxNotification.onData(1), RxNotification<int>.onDone()]);
    }));
  });

  test('materializeTransformer.happyPath', () async {
    final stream = Stream.fromIterable(const [1]);
    final notifications = <RxNotification<int>>[];

    stream
        .transform(MaterializeStreamTransformer<int>())
        .listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications,
          [RxNotification.onData(1), RxNotification<int>.onDone()]);
    }));
  });

  test('materializeTransformer.sadPath', () async {
    final stream = Stream<int>.error(Exception());
    final notifications = <RxNotification<int>>[];

    stream
        .transform(MaterializeStreamTransformer<int>())
        .listen(notifications.add,
            onError: expectAsync2((Exception e, StackTrace s) {
              // Check to ensure the stream does not come to this point
              expect(true, isFalse);
            }, count: 0), onDone: expectAsync0(() {
      expect(notifications.length, 2);
      expect(notifications[0].isOnError, isTrue);
      expect(notifications[1].isOnDone, isTrue);
    }));
  });

  test('materializeTransformer.onPause.onResume', () async {
    final stream = Stream.fromIterable(const [1]);
    final notifications = <RxNotification<int>>[];

    stream
        .transform(MaterializeStreamTransformer<int>())
        .listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications, <RxNotification<int>>[
        RxNotification.onData(1),
        RxNotification<int>.onDone()
      ]);
    }))
      ..pause()
      ..resume();
  });

  test('Rx.materialize accidental broadcast', () async {
    final controller = StreamController<int>();

    final stream = controller.stream.materialize();

    stream.listen(null);
    expect(() => stream.listen(null), throwsStateError);

    controller.add(1);
  });

  test('Rx.materialize.nullable', () {
    nullableTest<RxNotification<String?>>(
      (s) => s.materialize(),
    );
  });
}
