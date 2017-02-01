import 'dart:async';

StreamTransformer<T, T> doTransformer<T>(
    {void onCancel() = defaultOnCancel,
    void onData(T event) = defaultOnData,
    void onDone() = defaultOnDone,
    void onEach(Notification<T> notification) = defaultOnEach,
    Function onError = defaultOnError,
    void onListen() = defaultOnListen,
    void onPause([Future<dynamic> resumeSignal]) = defaultOnPause,
    void onResume() = defaultOnResume}) {
  return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
            onListen();

          subscription = input.listen((T value) {
              onData(value);

              onEach(new Notification<T>(Kind.OnData, value, null));

            controller.add(value);
          }, onError: (dynamic e, dynamic s) {
              onError(e, s);

              onEach(new Notification<T>(
                  Kind.OnError, null, new ErrorAndStackTrace(e, s)));

            controller.addError(e);
          }, onDone: () {
              onDone();

              onEach(new Notification<T>(Kind.OnDone, null, null));

            controller.close();
          }, cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) {
            onPause(resumeSignal);

          subscription.pause(resumeSignal);
        },
        onResume: () {
            onResume();

          subscription.resume();
        },
        onCancel: () {
            onCancel();

          subscription.cancel();
        });

    return controller.stream.listen(null);
  });
}

void defaultOnCancel() {}
void defaultOnData<T>(T event) {}
void defaultOnDone() {}
void defaultOnEach<T>(Notification<T> notification) {}
void defaultOnError(dynamic e, dynamic s) {}
void defaultOnListen() {}
void defaultOnPause([Future<dynamic> resumeSignal]) {}
void defaultOnResume() {}

enum Kind { OnData, OnDone, OnError }

class Notification<T> {
  final Kind _kind;
  final T _value;
  final ErrorAndStackTrace _errorAndStackTrace;

  Notification(this._kind, this._value, this._errorAndStackTrace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Notification &&
        this._kind == other._kind &&
        this._errorAndStackTrace == other._errorAndStackTrace &&
        this._value == other._value;
  }

  @override
  int get hashCode {
    return _kind.hashCode ^ _errorAndStackTrace.hashCode ^ _value.hashCode;
  }

  @override
  String toString() {
    return 'Notification{_kind: $_kind, _throwable: $_errorAndStackTrace, _value: $_value}';
  }
}

class ErrorAndStackTrace {
  final dynamic error;
  final dynamic stacktrace;

  ErrorAndStackTrace(this.error, this.stacktrace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ErrorAndStackTrace &&
        this.error == other.error &&
        this.stacktrace == other.stacktrace;
  }

  @override
  int get hashCode {
    return error.hashCode ^ stacktrace.hashCode;
  }

  @override
  String toString() {
    return 'ErrorAndStackTrace{error: $error, stacktrace: $stacktrace}';
  }
}
