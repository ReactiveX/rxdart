import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:test/test.dart';

void main() {
  group('DoStreamTranformer', () {
    test('calls onDone when the stream is finished', () async {
      bool onDoneCalled = false;
      final Observable<int> observable =
          new Observable<int>.empty().doOnDone(() => onDoneCalled = true);

      await expectLater(observable, emitsDone);
      await expectLater(onDoneCalled, isTrue);
    });

    test('calls onError when an error is emitted', () async {
      bool onErrorCalled = false;
      final Observable<int> observable =
          new Observable<int>.error(new Exception())
              .doOnError((dynamic e, dynamic s) => onErrorCalled = true);

      await expectLater(observable, emitsError(isException));
      await expectLater(onErrorCalled, isTrue);
    });

    test(
        'onError only called once when an error is emitted on a broadcast stream',
        () async {
      int count = 0;
      final BehaviorSubject<int> subject = new BehaviorSubject<int>(sync: true);
      final Stream<int> stream = subject.stream.doOnError(
        (dynamic e, dynamic s) => count++,
      );

      stream.listen(null, onError: (dynamic e, dynamic s) {});
      stream.listen(null, onError: (dynamic e, dynamic s) {});

      subject.addError(new Exception());
      subject.addError(new Exception());

      await expectLater(count, 2);
      await subject.close();
    });

    test('calls onCancel when the subscription is cancelled', () async {
      bool onCancelCalled = false;
      final Observable<int> observable = new Observable<int>.just(1);

      await observable
          .doOnCancel(() => onCancelCalled = true)
          .listen(null)
          .cancel();

      await expectLater(onCancelCalled, isTrue);
    });

    test(
        'onCancel called only once when the subscription is multiple listeners',
        () async {
      int count = 0;
      final BehaviorSubject<int> subject = new BehaviorSubject<int>(sync: true);
      final Observable<int> observable = subject.doOnCancel(() => count++);

      observable.listen(null);
      await observable.listen(null).cancel();

      await expectLater(count, 1);
      await subject.close();
    });

    test('calls onData when the observable emits an item', () async {
      bool onDataCalled = false;
      final Observable<int> observable =
          new Observable<int>.just(1).doOnData((int i) => onDataCalled = true);

      await expectLater(observable, emits(1));
      await expectLater(onDataCalled, isTrue);
    });

    test('onData only emits once for broadcast streams with multiple listeners',
        () async {
      final List<int> actual = <int>[];
      final StreamController<int> controller =
          new StreamController<int>.broadcast(sync: true);
      final Stream<int> observable = controller.stream
          .transform(new DoStreamTransformer<int>(onData: actual.add));

      observable.listen(null);
      observable.listen(null);

      controller.add(1);
      controller.add(2);

      await expectLater(actual, <int>[1, 2]);
      await controller.close();
    });

    test('emits onEach Notifications for Data, Error, and Done', () async {
      StackTrace stacktrace;
      final List<Notification<int>> actual = <Notification<int>>[];
      final Exception exception = new Exception();
      final Observable<int> observable = new Observable<int>.just(1)
          .concatWith(<Stream<int>>[
        new Observable<int>.error(exception)
      ]).doOnEach((Notification<int> notification) {
        actual.add(notification);

        if (notification.isOnError) {
          stacktrace = notification.stackTrace;
        }
      });

      await expectLater(observable,
          emitsInOrder(<dynamic>[1, emitsError(isException), emitsDone]));

      await expectLater(actual, <Notification<int>>[
        new Notification<int>.onData(1),
        new Notification<int>.onError(exception, stacktrace),
        new Notification<int>.onDone()
      ]);
    });

    test('onEach only emits once for broadcast streams with multiple listeners',
        () async {
      int count = 0;
      final StreamController<int> controller =
          new StreamController<int>.broadcast(sync: true);
      final Stream<int> observable =
          controller.stream.transform(new DoStreamTransformer<int>(onEach: (_) {
        count++;
      }));

      observable.listen(null);
      observable.listen(null);

      controller.add(1);
      controller.add(2);

      await expectLater(count, 2);
      await controller.close();
    });

    test('calls onListen when a consumer listens', () async {
      bool onListenCalled = false;
      final Observable<num> observable =
          new Observable<num>.empty().doOnListen(() {
        onListenCalled = true;
      });

      await expectLater(observable, emitsDone);
      await expectLater(onListenCalled, isTrue);
    });

    test('calls onListen every time a consumer listens to a broadcast stream',
        () async {
      int onListenCallCount = 0;
      final StreamController<int> sc = new StreamController<int>.broadcast()
        ..add(1)
        ..add(2)
        ..add(3);

      final Observable<int> observable =
          new Observable<int>(sc.stream).doOnListen(() => onListenCallCount++);

      observable.listen(null);
      observable.listen(null);

      await expectLater(onListenCallCount, 2);
      await sc.close();
    });

    test('calls onPause and onResume when the subscription is', () async {
      bool onPauseCalled = false;
      bool onResumeCalled = false;
      final Observable<num> observable =
          new Observable<num>.just(1).doOnPause((_) {
        onPauseCalled = true;
      }).doOnResume(() {
        onResumeCalled = true;
      });

      observable.listen((_) {}, onDone: expectAsync0(() {
        expect(onPauseCalled, isTrue);
        expect(onResumeCalled, isTrue);
      }))
        ..pause()
        ..resume();
    });

    test('should be reusable', () async {
      int callCount = 0;
      final DoStreamTransformer<int> transformer =
          new DoStreamTransformer<int>(onData: (_) {
        callCount++;
      });

      final Observable<int> observableA =
          new Observable<int>.just(1).transform(transformer);
      final Observable<int> observableB =
          new Observable<int>.just(1).transform(transformer);

      observableA.listen((_) {}, onDone: expectAsync0(() {
        expect(callCount, 2);
      }));

      observableB.listen((_) {}, onDone: expectAsync0(() {
        expect(callCount, 2);
      }));
    });

    test('throws an error when no arguments are provided', () {
      expect(() => new DoStreamTransformer<int>(), throwsArgumentError);
    });

    test('should propagate errors', () {
      new Observable<int>.just(1)
          .doOnListen(
              () => throw new Exception('catch me if you can! doOnListen'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException)));

      new Observable<int>.just(1)
          .doOnData((_) => throw new Exception('catch me if you can! doOnData'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException)));

      new Observable<int>.error(new Exception('oh noes!'))
          .doOnError((dynamic _, dynamic __) =>
              throw new Exception('catch me if you can! doOnError'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException),
                  count: 2));

      // a cancel() call may occur after the controller is already closed
      // in that case, the error is forwarded to the current [Zone]
      runZoned(
        () {
          new Observable<int>.just(1)
              .doOnCancel(() =>
                  throw new Exception('catch me if you can! doOnCancel-zoned'))
              .listen(null);

          new Observable<int>.just(1)
              .doOnCancel(
                  () => throw new Exception('catch me if you can! doOnCancel'))
              .listen(null)
                ..cancel();
        },
        onError: expectAsync2(
          (Exception e, [StackTrace s]) => expect(e, isException),
        ),
      );

      new Observable<int>.just(1)
          .doOnDone(() => throw new Exception('catch me if you can! doOnDone'))
          .listen(
            null,
            onError: expectAsync2(
              (Exception e, [StackTrace s]) => expect(e, isException),
            ),
          );

      new Observable<int>.just(1)
          .doOnEach((_) => throw new Exception('catch me if you can! doOnEach'))
          .listen(
            null,
            onError: expectAsync2(
              (Exception e, [StackTrace s]) => expect(e, isException),
              count: 2,
            ),
          );

      new Observable<int>.just(1)
          .doOnPause(
              (_) => throw new Exception('catch me if you can! doOnPause'))
          .listen(null,
              onError: expectAsync2(
                (Exception e, [StackTrace s]) => expect(e, isException),
              ))
            ..pause()
            ..resume();

      new Observable<int>.just(1)
          .doOnResume(
              () => throw new Exception('catch me if you can! doOnResume'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException)))
            ..pause()
            ..resume();
    });
  });
}
