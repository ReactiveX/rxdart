import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/never.dart';
import 'package:test/test.dart';

void main() {
  test('NeverStream', () async {
    bool onDataCalled = false;
    bool onDoneCalled = false;
    bool onErrorCalled = false;

    Stream<int> stream = new NeverStream<int>();

    StreamSubscription<int> subscription = stream.listen(
        expectAsync1((int actual) {
          onDataCalled = true;
        }, count: 0),
        onError: expectAsync2((Exception e, StackTrace s) {
          onErrorCalled = false;
        }, count: 0),
        onDone: expectAsync0(() {
          onDataCalled = true;
        }, count: 0));

    await new Future<int>.delayed(new Duration(milliseconds: 10));

    await subscription.cancel();

    // We do not expect onData, onDone, nor onError to be called, as [never]
    // streams emit no items or errors, and they do not terminate
    await expectLater(onDataCalled, isFalse);
    await expectLater(onDoneCalled, isFalse);
    await expectLater(onErrorCalled, isFalse);
  });

  test('NeverStream.single.subscription', () async {
    final NeverStream<int> stream = new NeverStream<int>();

    stream.listen((_) {});
    await expectLater(() => stream.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.never', () async {
    bool onDataCalled = false;
    bool onDoneCalled = false;
    bool onErrorCalled = false;

    Observable<int> observable = new Observable<int>.never();

    StreamSubscription<int> subscription = observable.listen(
        expectAsync1((int actual) {
          onDataCalled = true;
        }, count: 0),
        onError: expectAsync2((Exception e, StackTrace s) {
          onErrorCalled = false;
        }, count: 0),
        onDone: expectAsync0(() {
          onDataCalled = true;
        }, count: 0));

    await new Future<int>.delayed(new Duration(milliseconds: 10));

    await subscription.cancel();

    // We do not expect onData, onDone, nor onError to be called, as [never]
    // streams emit no items or errors, and they do not terminate
    await expectLater(onDataCalled, isFalse);
    await expectLater(onDoneCalled, isFalse);
    await expectLater(onErrorCalled, isFalse);
  });
}
