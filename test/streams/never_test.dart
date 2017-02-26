import 'dart:async';

import 'package:rxdart/src/streams/never.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

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
        onError: expectAsync2((dynamic e, dynamic s) {
          onErrorCalled = false;
        }, count: 0),
        onDone: expectAsync0(() {
          onDataCalled = true;
        }, count: 0));

    await new Future<int>.delayed(new Duration(milliseconds: 10));

    await subscription.cancel();

    // We do not expect onData, onDone, nor onError to be called, as [never]
    // streams emit no items or errors, and they do not terminate
    await expect(onDataCalled, isFalse);
    await expect(onDoneCalled, isFalse);
    await expect(onErrorCalled, isFalse);
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
        onError: expectAsync2((dynamic e, dynamic s) {
          onErrorCalled = false;
        }, count: 0),
        onDone: expectAsync0(() {
          onDataCalled = true;
        }, count: 0));

    await new Future<int>.delayed(new Duration(milliseconds: 10));

    await subscription.cancel();

    // We do not expect onData, onDone, nor onError to be called, as [never]
    // streams emit no items or errors, and they do not terminate
    await expect(onDataCalled, isFalse);
    await expect(onDoneCalled, isFalse);
    await expect(onErrorCalled, isFalse);
  });
}
