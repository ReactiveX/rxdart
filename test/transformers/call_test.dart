import '../test_utils.dart';
import 'dart:async';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.call', () async {
    final Observable<int> observable =
        new Observable<int>.just(1).call(onDone: () {});

    observable.listen(expectAsync1((int item) {
      expect(item, 1);
    }), onDone: expectAsync0(() {
      // Should reach here
      expect(true, true);
    }));
  });

  test('rx.Observable.call.error', () async {
    final Observable<int> observable =
        new Observable<num>(getErroneousStream()).call(onData: (_) {});

    observable.listen((_) {}, onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.call.onCancel', () async {
    final Observable<int> observable = new Observable<int>.just(1);

    bool onCancelCalled = false;

    await observable
        .call(onCancel: () {
          onCancelCalled = true;
        })
        .listen(null)
        .cancel();

    expect(onCancelCalled, isTrue);
  });

  test('rx.Observable.call.onData', () async {
    final Observable<int> observable = new Observable<int>.just(1);

    bool onDataCalled = false;

    observable.call(onData: (_) {
      onDataCalled = true;
    }).listen((_) {}, onDone: expectAsync0(() {
      expect(onDataCalled, isTrue);
    }));
  });

  test('rx.Observable.call.onDone', () async {
    final Observable<int> observable = new Observable<int>.just(1);

    bool onDoneCalled = false;

    observable.call(onDone: () {
      onDoneCalled = true;
    }).listen((_) {}, onDone: expectAsync0(() {
      expect(onDoneCalled, isTrue);
    }));
  });

  test('rx.Observable.call.onError', () async {
    final Observable<num> observable =
        new Observable<num>(getErroneousStream());
    bool onErrorCalled = false;

    observable.call(onError: (_, __) {
      onErrorCalled = true;
    }).listen((_) {}, onError: expectAsync2((dynamic e, dynamic s) {
      expect(onErrorCalled, isTrue);
    }));
  });

  test('rx.Observable.call.onEach.happyPath', () async {
    final Observable<int> observable = new Observable<int>.just(1);
    List<Notification<int>> notifications = <Notification<int>>[];

    observable.call(onEach: (Notification<int> notification) {
      notifications.add(notification);
    }).listen((_) {}, cancelOnError: false, onDone: expectAsync0(() {
      expect(notifications, <Notification<int>>[
        new Notification<int>(Kind.OnData, 1, null),
        new Notification<int>(Kind.OnDone, null, null)
      ]);
    }));
  });

  test('rx.Observable.call.onEach.sadPath', () async {
    final Observable<num> observable =
        new Observable<num>(getErroneousStream());
    List<Notification<num>> notifications = <Notification<num>>[];

    observable.call(onEach: (Notification<num> notification) {
      notifications.add(notification);
    }).listen((_) {}, onError: expectAsync2((dynamic e, dynamic s) {
      expect(notifications.length, 1);
      expect(notifications[0].kind, Kind.OnError);
      expect(notifications[0].errorAndStackTrace.error, isException);
      expect(notifications[0].errorAndStackTrace.stacktrace is Chain, isTrue);
    }));
  });

  test('rx.Observable.call.onListen', () async {
    final Observable<num> observable = new Observable<num>.just(1);
    bool onListenCalled = false;

    observable.call(onListen: () {
      onListenCalled = true;
    }).listen((_) {});

    expect(onListenCalled, isTrue);
  });

  test('rx.Observable.call.onPause.onResume', () async {
    final Observable<num> observable = new Observable<num>.just(1);
    bool onPauseCalled = false;
    bool onResumeCalled = false;

    observable.call(onPause: (_) {
      onPauseCalled = true;
    }, onResume: () {
      onResumeCalled = true;
    }).listen((_) {}, onDone: expectAsync0(() {
      expect(onPauseCalled, isTrue);
      expect(onResumeCalled, isTrue);
    }))
      ..pause()
      ..resume();
  });

  test('rx.Observable.call.noArgs', () async {
    final Observable<int> observable =
        new Observable<int>.just(1).call(onDone: () {});

    try {
      // If call contains no arguments, throw a runtime error in dev mode
      // in order to "fail fast" and alert the developer that the operator
      // can be used or safely removed.
      observable.call();
    } catch (e, s) {
      expect(e is AssertionError, isTrue);
    }
  });
}
