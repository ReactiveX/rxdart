import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.materialize.happyPath', () async {
    final Observable<int> observable = new Observable<int>.just(1);
    List<Notification<int>> notifications = <Notification<int>>[];

    observable.materialize().listen((Notification<int> notification) {
      notifications.add(notification);
    }, onDone: expectAsync0(() {
      expect(notifications, <Notification<int>>[
        new Notification<int>.onData(1),
        new Notification<int>.onDone()
      ]);
    }));
  });

  test('rx.Observable.materialize.reusable', () async {
    final MaterializeStreamTransformer<int> transformer =
        new MaterializeStreamTransformer<int>();
    final Observable<int> observable =
        new Observable<int>.just(1).asBroadcastStream();
    List<Notification<int>> notificationsA = <Notification<int>>[],
        notificationsB = <Notification<int>>[];

    observable.transform(transformer).listen((Notification<int> notification) {
      notificationsA.add(notification);
    }, onDone: expectAsync0(() {
      expect(notificationsA, <Notification<int>>[
        new Notification<int>.onData(1),
        new Notification<int>.onDone()
      ]);
    }));

    observable.transform(transformer).listen((Notification<int> notification) {
      notificationsB.add(notification);
    }, onDone: expectAsync0(() {
      expect(notificationsB, <Notification<int>>[
        new Notification<int>.onData(1),
        new Notification<int>.onDone()
      ]);
    }));
  });

  test('materializeTransformer.happyPath', () async {
    final Stream<int> stream = new Stream<int>.fromIterable(<int>[1]);
    List<Notification<int>> notifications = <Notification<int>>[];

    stream.transform(new MaterializeStreamTransformer<int>()).listen(
        (Notification<int> notification) {
      notifications.add(notification);
    }, onDone: expectAsync0(() {
      expect(notifications, <Notification<int>>[
        new Notification<int>.onData(1),
        new Notification<int>.onDone()
      ]);
    }));
  });

  test('materializeTransformer.sadPath', () async {
    final Stream<num> stream = new ErrorStream<int>(new Exception());
    List<Notification<int>> notifications = <Notification<int>>[];

    stream.transform(new MaterializeStreamTransformer<int>()).listen(
        (Notification<int> notification) {
          notifications.add(notification);
        },
        onError: expectAsync2((Exception e, StackTrace s) {
          // Check to ensure the stream does not come to this point
          expect(true, isFalse);
        }, count: 0),
        onDone: expectAsync0(() {
          expect(notifications.length, 2);
          expect(notifications[0].isOnError, isTrue);
          expect(notifications[1].isOnDone, isTrue);
        }));
  });

  test('materializeTransformer.onPause.onResume', () async {
    final Stream<int> stream = new Stream<int>.fromIterable(<int>[1]);
    List<Notification<int>> notifications = <Notification<int>>[];

    stream.transform(new MaterializeStreamTransformer<int>()).listen(
        (Notification<int> notification) {
      notifications.add(notification);
    }, onDone: expectAsync0(() {
      expect(notifications, <Notification<int>>[
        new Notification<int>.onData(1),
        new Notification<int>.onDone()
      ]);
    }))
      ..pause()
      ..resume();
  });
}
