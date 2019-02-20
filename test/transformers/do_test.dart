import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:test/test.dart';

void main() {
  group('DoStreamTranformer', () {
    test('calls onDone when the stream is finished', () async {
      var onDoneCalled = false;
      final observable =
          Observable<void>.empty().doOnDone(() => onDoneCalled = true);

      await expectLater(observable, emitsDone);
      await expectLater(onDoneCalled, isTrue);
    });

    test('calls onError when an error is emitted', () async {
      var onErrorCalled = false;
      final observable = Observable<void>.error(Exception())
          .doOnError((dynamic e, dynamic s) => onErrorCalled = true);

      await expectLater(observable, emitsError(isException));
      await expectLater(onErrorCalled, isTrue);
    });

    test(
        'onError only called once when an error is emitted on a broadcast stream',
        () async {
      var count = 0;
      final subject = BehaviorSubject<int>(sync: true);
      final stream = subject.stream.doOnError(
        (dynamic e, dynamic s) => count++,
      );

      stream.listen(null, onError: (dynamic e, dynamic s) {});
      stream.listen(null, onError: (dynamic e, dynamic s) {});

      subject.addError(Exception());
      subject.addError(Exception());

      await expectLater(count, 2);
      await subject.close();
    });

    test('calls onCancel when the subscription is cancelled', () async {
      var onCancelCalled = false;
      final observable = Observable.just(1);

      await observable
          .doOnCancel(() => onCancelCalled = true)
          .listen(null)
          .cancel();

      await expectLater(onCancelCalled, isTrue);
    });

    test('awaits onCancel when the subscription is cancelled', () async {
      var onCancelCompleted = 10, onCancelHandled = 10, eventSequenceCount = 0;
      final observable = Observable.just(1);

      await observable
          .doOnCancel(() =>
              Future<void>.delayed(const Duration(milliseconds: 100))
                  .whenComplete(() => onCancelHandled = ++eventSequenceCount))
          .listen(null)
          .cancel()
          .whenComplete(() => onCancelCompleted = ++eventSequenceCount);

      await expectLater(onCancelCompleted > onCancelHandled, isTrue);
    });

    test(
        'onCancel called only once when the subscription is multiple listeners',
        () async {
      var count = 0;
      final subject = BehaviorSubject<int>(sync: true);
      final observable = subject.doOnCancel(() => count++);

      observable.listen(null);
      await observable.listen(null).cancel();

      await expectLater(count, 1);
      await subject.close();
    });

    test('calls onData when the observable emits an item', () async {
      var onDataCalled = false;
      final observable =
          Observable.just(1).doOnData((_) => onDataCalled = true);

      await expectLater(observable, emits(1));
      await expectLater(onDataCalled, isTrue);
    });

    test('onData only emits once for broadcast streams with multiple listeners',
        () async {
      final actual = <int>[];
      final controller = StreamController<int>.broadcast(sync: true);
      final observable =
          controller.stream.transform(DoStreamTransformer(onData: actual.add));

      observable.listen(null);
      observable.listen(null);

      controller.add(1);
      controller.add(2);

      await expectLater(actual, const [1, 2]);
      await controller.close();
    });

    test('emits onEach Notifications for Data, Error, and Done', () async {
      StackTrace stacktrace;
      final actual = <Notification<int>>[];
      final exception = Exception();
      final observable = Observable.just(1).concatWith(
          [Observable<int>.error(exception)]).doOnEach((notification) {
        actual.add(notification);

        if (notification.isOnError) {
          stacktrace = notification.stackTrace;
        }
      });

      await expectLater(observable,
          emitsInOrder(<dynamic>[1, emitsError(isException), emitsDone]));

      await expectLater(actual, [
        Notification.onData(1),
        Notification<void>.onError(exception, stacktrace),
        Notification<void>.onDone()
      ]);
    });

    test('onEach only emits once for broadcast streams with multiple listeners',
        () async {
      var count = 0;
      final controller = StreamController<int>.broadcast(sync: true);
      final observable =
          controller.stream.transform(DoStreamTransformer(onEach: (_) {
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
      var onListenCalled = false;
      final observable = Observable<void>.empty().doOnListen(() {
        onListenCalled = true;
      });

      await expectLater(observable, emitsDone);
      await expectLater(onListenCalled, isTrue);
    });

    test('calls onListen every time a consumer listens to a broadcast stream',
        () async {
      var onListenCallCount = 0;
      final sc = StreamController<int>.broadcast()..add(1)..add(2)..add(3);

      final observable =
          Observable(sc.stream).doOnListen(() => onListenCallCount++);

      observable.listen(null);
      observable.listen(null);

      await expectLater(onListenCallCount, 2);
      await sc.close();
    });

    test('calls onPause and onResume when the subscription is', () async {
      var onPauseCalled = false, onResumeCalled = false;
      final observable = Observable.just(1).doOnPause((_) {
        onPauseCalled = true;
      }).doOnResume(() {
        onResumeCalled = true;
      });

      observable.listen(null, onDone: expectAsync0(() {
        expect(onPauseCalled, isTrue);
        expect(onResumeCalled, isTrue);
      }))
        ..pause()
        ..resume();
    });

    test('should be reusable', () async {
      var callCount = 0;
      final transformer = DoStreamTransformer<int>(onData: (_) {
        callCount++;
      });

      final observableA = Observable.just(1).transform(transformer),
          observableB = Observable.just(1).transform(transformer);

      observableA.listen(null, onDone: expectAsync0(() {
        expect(callCount, 2);
      }));

      observableB.listen(null, onDone: expectAsync0(() {
        expect(callCount, 2);
      }));
    });

    test('throws an error when no arguments are provided', () {
      expect(() => DoStreamTransformer<void>(), throwsArgumentError);
    });

    test('should propagate errors', () {
      Observable.just(1)
          .doOnListen(() => throw Exception('catch me if you can! doOnListen'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException)));

      Observable.just(1)
          .doOnData((_) => throw Exception('catch me if you can! doOnData'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException)));

      Observable<void>.error(Exception('oh noes!'))
          .doOnError((dynamic _, dynamic __) =>
              throw Exception('catch me if you can! doOnError'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException),
                  count: 2));

      // a cancel() call may occur after the controller is already closed
      // in that case, the error is forwarded to the current [Zone]
      runZoned(
        () {
          Observable.just(1)
              .doOnCancel(() =>
                  throw Exception('catch me if you can! doOnCancel-zoned'))
              .listen(null);

          Observable.just(1)
              .doOnCancel(
                  () => throw Exception('catch me if you can! doOnCancel'))
              .listen(null)
                ..cancel();
        },
        onError: expectAsync2(
          (Exception e, [StackTrace s]) => expect(e, isException),
        ),
      );

      Observable.just(1)
          .doOnDone(() => throw Exception('catch me if you can! doOnDone'))
          .listen(
            null,
            onError: expectAsync2(
              (Exception e, [StackTrace s]) => expect(e, isException),
            ),
          );

      Observable.just(1)
          .doOnEach((_) => throw Exception('catch me if you can! doOnEach'))
          .listen(
            null,
            onError: expectAsync2(
              (Exception e, [StackTrace s]) => expect(e, isException),
              count: 2,
            ),
          );

      Observable.just(1)
          .doOnPause((_) => throw Exception('catch me if you can! doOnPause'))
          .listen(null,
              onError: expectAsync2(
                (Exception e, [StackTrace s]) => expect(e, isException),
              ))
            ..pause()
            ..resume();

      Observable.just(1)
          .doOnResume(() => throw Exception('catch me if you can! doOnResume'))
          .listen(null,
              onError: expectAsync2(
                  (Exception e, [StackTrace s]) => expect(e, isException)))
            ..pause()
            ..resume();
    });
  });
}
