import 'dart:async';

/// Invokes each callback at the given point in the stream lifecycle
///
/// This method can be used for debugging, logging, etc. by intercepting the
/// stream at different points to run arbitrary actions.
///
/// It is possible to hook onto the following parts of the stream lifecycle:
///
///   - onCancel
///   - onData
///   - onDone
///   - onError
///   - onListen
///   - onPause
///   - onResume
///
/// In addition, the `onEach` argument is called at `onData`, `onDone`, and
/// `onError` with a [Notification] passed in. The [Notification] argument
/// contains the [Kind] of event (OnData, OnDone, OnError), and the item or
/// error that was emitted. In the case of onDone, no data is emitted as part
/// of the [Notification].
///
/// If no callbacks are passed in, a runtime error will be thrown in dev mode
/// in order to "fail fast" and alert the developer that the operator should be
/// used or safely removed.
///
/// ### Example
///
///     new Stream.fromIterable([1])
///         .transform(callTransformer(onData: (i) => print(i))); // Prints: 1
StreamTransformer<T, T> callTransformer<T>(
    {void onCancel(),
    void onData(T event),
    void onDone(),
    void onEach(Notification<T> notification),
    Function onError,
    void onListen(),
    void onPause(Future<dynamic> resumeSignal),
    void onResume()}) {
  assert(onCancel != null ||
      onData != null ||
      onDone != null ||
      onEach != null ||
      onError != null ||
      onListen != null ||
      onPause != null ||
      onResume != null);

  return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = new StreamController<T>(
        sync: true,
        onListen: () {
          if (onListen != null) {
            onListen();
          }

          subscription = input.listen((T value) {
            if (onData != null) {
              onData(value);
            }

            if (onEach != null) {
              onEach(new Notification<T>(Kind.OnData, value, null));
            }

            controller.add(value);
          }, onError: (dynamic e, dynamic s) {
            if (onError != null) {
              onError(e, s);
            }

            if (onEach != null) {
              onEach(new Notification<T>(
                  Kind.OnError, null, new ErrorAndStackTrace(e, s)));
            }

            controller.addError(e);
          }, onDone: () {
            if (onDone != null) {
              onDone();
            }

            if (onEach != null) {
              onEach(new Notification<T>(Kind.OnDone, null, null));
            }

            controller.close();
          }, cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) {
          if (onPause != null) {
            onPause(resumeSignal);
          }

          subscription.pause(resumeSignal);
        },
        onResume: () {
          if (onResume != null) {
            onResume();
          }

          subscription.resume();
        },
        onCancel: () {
          if (onCancel != null) {
            onCancel();
          }

          return subscription.cancel();
        });

    return controller.stream.listen(null);
  });
}

enum Kind { OnData, OnDone, OnError }

class Notification<T> {
  final Kind kind;
  final T value;
  final ErrorAndStackTrace errorAndStackTrace;

  Notification(this.kind, this.value, this.errorAndStackTrace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Notification &&
        this.kind == other.kind &&
        this.errorAndStackTrace == other.errorAndStackTrace &&
        this.value == other.value;
  }

  @override
  int get hashCode {
    return kind.hashCode ^ errorAndStackTrace.hashCode ^ value.hashCode;
  }

  @override
  String toString() {
    return 'Notification{kind: $kind, _throwable: $errorAndStackTrace, value: $value}';
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
