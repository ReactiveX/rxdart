import 'dart:async';

class UsingStream<T> extends Stream<T> {
  final Disposable<T> disposable;

  UsingStream(this.disposable);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    StreamController<T> controller;

    Future<dynamic> doDispose() {
      try {
        return disposable.dispose()
          ..catchError((e, s) => controller.addError(e, s));
      } catch (error) {
        controller.addError(error);
      }

      return new Future<dynamic>.value();
    }

    controller = new StreamController<T>(
        onListen: () => controller..add(disposable.value),
        onCancel: () => Future.wait(<Future<dynamic>>[
              doDispose(),
              controller.close()
            ].where((Future<dynamic> future) => future != null)));

    return controller.stream.listen(onData, onError: onError, onDone: () async {
      await doDispose();
      onDone();
    }, cancelOnError: cancelOnError);
  }

  @override
  Stream<T> asBroadcastStream(
      {void onListen(StreamSubscription<T> subscription),
      void onCancel(StreamSubscription<T> subscription)}) {
    throw new Exception(
        'cannot create broadcastStream from a disposable resource');
  }
}

abstract class Disposable<T> {
  T value;
  bool isDisposed = false;

  Disposable(this.value);

  Future<dynamic> dispose();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Disposable && this.value == other.value;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  String toString() {
    return 'Disposable{value: $value}';
  }
}
