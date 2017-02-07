import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

class TestDisposable<T> extends Disposable<T> {
  TestDisposable(T value) : super(value);

  @override
  Future<dynamic> dispose() {
    value = null;

    return new Future<dynamic>.value();
  }
}

class ErrorDisposable<T> extends Disposable<T> {
  ErrorDisposable(T value) : super(value);

  @override
  Future<dynamic> dispose() {
    throw new Exception();
  }
}

class DisposableObject {
  int value = 42;

  Future<dynamic> dispose() =>
      new Future<dynamic>.value()..whenComplete(() => value = null);
}

class TestDisposableObject<T extends DisposableObject> extends Disposable<T> {
  TestDisposableObject(T value) : super(value);

  @override
  Future<dynamic> dispose() => value.dispose();
}

void main() {
  test('rx.Observable.using', () async {
    StreamSubscription<int> subscription;

    subscription = new Observable.using(new TestDisposable<int>(42))
        .listen(expectAsync1((int result) {
      expect(result, 42);
      subscription.cancel();
    }, count: 1));
  });

  test('rx.Observable.using.asBroadcastStream', () async {
    /// asBroadcastStream should throw since we cannot call [dispose] on the [TestDisposable] this way
    try {
      new Observable.using(new TestDisposable<int>(42)).asBroadcastStream();
    } catch (error) {
      expect(error, isException);
    }
  });

  test('rx.Observable.using.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable.using(new ErrorDisposable<int>(42));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    })..cancel();
  });

  test('rx.Observable.using.error.shouldDispose', () async {
    StreamSubscription<DisposableObject> subscription;

    subscription = new Observable.using(
            new TestDisposableObject<DisposableObject>(new DisposableObject()))
        .listen(expectAsync1((DisposableObject result) {
      subscription
          .cancel()
          .then(expectAsync1((_) => expect(result.value, isNull)));
      expect(result.value, 42);
    }, count: 1));
  });

  test('rx.Observable.using.pause.resume', () async {
    StreamSubscription<DisposableObject> subscription;
    Observable<DisposableObject> stream = new Observable.using(
        new TestDisposableObject<DisposableObject>(new DisposableObject()));

    subscription = stream.listen(expectAsync1((DisposableObject result) {
      subscription
          .cancel()
          .then(expectAsync1((_) => expect(result.value, isNull)));
      expect(result.value, 42);
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
