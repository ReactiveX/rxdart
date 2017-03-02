import 'dart:async';
import 'package:rxdart/src/utils/as_observable_future.dart';
import 'package:test/test.dart';

void main() {
  test('AsObservableFuture.asObservable', () async {
    AsObservableFuture<int> future =
        new AsObservableFuture<int>(new Future<int>.value(1));

    await expect(future.asObservable(), emits(1));
  });

  test('AsObservableFuture.asStream', () async {
    AsObservableFuture<int> future =
        new AsObservableFuture<int>(new Future<int>.value(1));

    await expect(future.asStream(), emits(1));
  });

  test('AsObservableFuture.catchError', () async {
    bool catchErrorCalled = false;

    await new AsObservableFuture<int>(new Future<int>.error(new Exception()))
        .catchError((dynamic e, dynamic s) {
      catchErrorCalled = true;
    });

    await expect(catchErrorCalled, isTrue);
  });

  test('AsObservableFuture.then', () async {
    bool thenCalled = false;

    await new AsObservableFuture<int>(new Future<int>.value(1)).then((int i) {
      thenCalled = true;
    });

    await expect(thenCalled, isTrue);
  });

  test('AsObservableFuture.timeout', () async {
    await new AsObservableFuture<int>(new Future<int>.delayed(new Duration(minutes: 1))).timeout(new Duration(milliseconds: 1), onTimeout: () {
      // should execute
      expect(true, isTrue);
    });
  });

  test('AsObservableFuture.whenComplete', () async {
    await new AsObservableFuture<int>(new Future<int>.value(1)).whenComplete(() {
      expect(true, isTrue);
    });
  });
}
