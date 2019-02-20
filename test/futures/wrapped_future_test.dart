import 'dart:async';

import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:test/test.dart';

void main() {
  test('AsObservableFuture.asObservable', () async {
    final future = AsObservableFuture<int>(Future.value(1));

    await expectLater(future.asObservable(), emits(1));
  });

  group('WrappedFuture', () {
    test('can be converted to a stream', () async {
      final future = AsObservableFuture(Future.value(1));

      await expectLater(future.asStream(), emits(1));
    });

    test('properly handles catchError', () async {
      var catchErrorCalled = false;

      await AsObservableFuture<int>(Future<int>.error(Exception()))
          .catchError((dynamic e, dynamic s) {
        catchErrorCalled = true;
      });

      await expectLater(catchErrorCalled, isTrue);
    });

    test('handles then', () async {
      var thenCalled = false;

      await AsObservableFuture<int>(Future.value(1)).then((int i) {
        thenCalled = true;
      });

      await expectLater(thenCalled, isTrue);
    });

    test('handles timeout', () async {
      await expectLater(
          AsObservableFuture<int>(Future<int>.delayed(Duration(minutes: 1)))
              .timeout(Duration(milliseconds: 1)),
          throwsA(TypeMatcher<TimeoutException>()));
    });

    test('handles whenComplete callbacks', () async {
      var whenCompleteCalled = false;

      await AsObservableFuture(Future.value(1)).whenComplete(() {
        whenCompleteCalled = true;
      });

      await expectLater(whenCompleteCalled, isTrue);
    });
  });
}
