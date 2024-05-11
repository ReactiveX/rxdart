import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  test('Rx.materialize.happyPath', () async {
    final stream = Stream.value(1);
    final notifications = <StreamNotification<int>>[];

    stream.materialize().listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications,
          [StreamNotification.data(1), StreamNotification<int>.done()]);
    }));
  });

  test('Rx.materialize.reusable', () async {
    final transformer = MaterializeStreamTransformer<int>();
    final stream = Stream.value(1).asBroadcastStream();
    final notificationsA = <StreamNotification<int>>[],
        notificationsB = <StreamNotification<int>>[];

    stream.transform(transformer).listen(notificationsA.add,
        onDone: expectAsync0(() {
      expect(notificationsA,
          [StreamNotification.data(1), StreamNotification<int>.done()]);
    }));

    stream.transform(transformer).listen(notificationsB.add,
        onDone: expectAsync0(() {
      expect(notificationsB,
          [StreamNotification.data(1), StreamNotification<int>.done()]);
    }));
  });

  test('materializeTransformer.happyPath', () async {
    final stream = Stream.fromIterable(const [1]);
    final notifications = <StreamNotification<int>>[];

    stream
        .transform(MaterializeStreamTransformer<int>())
        .listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications,
          [StreamNotification.data(1), StreamNotification<int>.done()]);
    }));
  });

  test('materializeTransformer.sadPath', () async {
    final stream = Stream<int>.error(Exception());
    final notifications = <StreamNotification<int>>[];

    stream
        .transform(MaterializeStreamTransformer<int>())
        .listen(notifications.add,
            onError: expectAsync2((Exception e, StackTrace s) {
              // Check to ensure the stream does not come to this point
              expect(true, isFalse);
            }, count: 0), onDone: expectAsync0(() {
      expect(notifications.length, 2);
      expect(notifications[0].isError, isTrue);
      expect(notifications[1].isDone, isTrue);
    }));
  });

  test('materializeTransformer.onPause.onResume', () async {
    final stream = Stream.fromIterable(const [1]);
    final notifications = <StreamNotification<int>>[];

    stream
        .transform(MaterializeStreamTransformer<int>())
        .listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications, <StreamNotification<int>>[
        StreamNotification.data(1),
        StreamNotification<int>.done()
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
    nullableTest<StreamNotification<String?>>(
      (s) => s.materialize(),
    );
  });
}
