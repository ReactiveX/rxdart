import 'dart:async';

import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:test/test.dart';

void main() {
  test('AsObservableFuture.asObservable', () async {
    AsObservableFuture<int> future =
        new AsObservableFuture<int>(new Future<int>.value(1));

    await expectLater(future.asObservable(), emits(1));
  });

  group('WrappedFuture', () {
    test('can be converted to a stream', () async {
      AsObservableFuture<int> future =
          new AsObservableFuture<int>(new Future<int>.value(1));

      await expectLater(future.asStream(), emits(1));
    });

    test('properly handles catchError', () async {
      bool catchErrorCalled = false;

      await new AsObservableFuture<int>(new Future<int>.error(new Exception()))
          .catchError((dynamic e, dynamic s) {
        catchErrorCalled = true;
      });

      await expectLater(catchErrorCalled, isTrue);
    });

    test('handles then', () async {
      bool thenCalled = false;

      await new AsObservableFuture<int>(new Future<int>.value(1)).then((int i) {
        thenCalled = true;
      });

      await expectLater(thenCalled, isTrue);
    });

    test('handles timeout', () async {
      await expectLater(
          new AsObservableFuture<int>(
                  new Future<int>.delayed(new Duration(minutes: 1)))
              .timeout(new Duration(milliseconds: 1)),
          throwsA(new TypeMatcher<TimeoutException>()));
    });

    test('handles whenComplete callbacks', () async {
      bool whenCompleteCalled = false;

      await new AsObservableFuture<int>(new Future<int>.value(1))
          .whenComplete(() {
        whenCompleteCalled = true;
      });

      await expectLater(whenCompleteCalled, isTrue);
    });
  });
}
