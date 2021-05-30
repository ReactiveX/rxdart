import 'dart:async';

import 'package:rxdart/src/rx.dart';
import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// A Single is something like an [Stream], but instead of emitting a series of
/// values — anywhere from none at all to an infinite number — it always either
/// emits one value or an error notification.
class Single<T> extends StreamView<T> {
  Single._(Stream<T> stream) : super(stream);

  /// Creates a stream which emits a single error event before completing.
  ///
  /// This stream emits a single error event of [error] and [stackTrace]
  /// and then completes with a done event.
  ///
  /// See [Stream.error] for more information
  Single.error(Object error, [StackTrace? stackTrace])
      : this._(Stream.error(error, stackTrace));

  /// Creates a stream which emits a single data event before completing.
  ///
  /// This stream emits a single data event of [value]
  /// and then completes with a done event.
  ///
  /// See [Stream.value] for more information
  Single.value(T value) : this._(Stream.value(value));

  /// Creates a new single-subscription stream from the future.
  ///
  /// When the future completes, the stream will fire one event, either
  /// data or error, and then close with a done-event.
  ///
  /// See [Stream.fromFuture] for more information
  Single.fromFuture(Future<T> future) : this._(Stream.fromFuture(future));

  /// Transform a [Stream] that should output a single value or a single error
  /// to a [Single] stream
  Single.fromStream(Stream<T> stream)
      : this._(stream is Single<T> ? stream : _buildStream(stream));

  /// Returns a Stream that, when listening to it, calls a function you specify
  /// and then emits the value returned from that function.
  ///
  /// See [Rx.fromCallable] for more information
  Single.fromCallable(FutureOr<T> Function() callable)
      : this._(Rx.fromCallable(callable));

  /// See [Stream.asBroadcastStream] for documentation
  @override
  Single<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) {
    return Single.fromStream(
        super.asBroadcastStream(onListen: onListen, onCancel: onCancel));
  }

  /// See [Stream.map] for documentation
  @override
  Single<E> map<E>(E Function(T event) convert) => Single._(super.map(convert));

  /// See [Stream.asyncMap] for documentation
  @override
  Single<E> asyncMap<E>(FutureOr<E> Function(T event) convert) =>
      Single._(super.asyncMap(convert));

  /// See [Stream.handleError] for documentation
  @override
  Single<T> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
    return Single._(super.handleError(onError, test: test));
  }

  /// See [Stream.cast] for documentation
  @override
  Single<R> cast<R>() => Single._(super.cast());

  /// See [Stream.distinct] for documentation
  @override
  Single<T> distinct([bool Function(T previous, T next)? equals]) => this;

  static Stream<T> _buildStream<T>(Stream<T> source) {
    final controller = source.isBroadcast
        ? StreamController<T>.broadcast(sync: true)
        : StreamController<T>(sync: true);
    StreamSubscription<T>? subscription;

    controller.onListen = () {
      var hasValue = false;
      T? value;
      ErrorAndStackTrace? error;

      subscription = source.listen(
        (data) {
          if (hasValue) {
            controller.addError(
                SingleError('Stream contains more than one data event.',
                    data: data),
                StackTrace.current);
            controller.close();
            return;
          }
          if (error != null) {
            controller.addError(
                SingleError('Stream contains both data and error event.',
                    data: data),
                StackTrace.current);
            controller.close();
            return;
          }
          hasValue = true;
          value = data;
        },
        onError: (Object e, StackTrace s) {
          final newError = ErrorAndStackTrace(e, s);

          if (error != null) {
            controller.addError(
                SingleError('Stream contains more than one error event.',
                    error: newError),
                StackTrace.current);
            controller.close();
            return;
          }
          if (hasValue) {
            controller.addError(
                SingleError('Stream contains both data and error event.',
                    error: newError),
                StackTrace.current);
            controller.close();
            return;
          }

          error = newError;
        },
        onDone: () {
          if (!hasValue && error == null) {
            controller.addError(
                SingleError("Stream doesn't contains any data or error event."),
                StackTrace.current);
            controller.close();
            return;
          }

          if (error != null) {
            controller.addError(error!.error, error!.stackTrace);
            controller.close();
            return;
          }

          controller.add(value as T);
          controller.close();
        },
      );

      if (!source.isBroadcast) {
        controller
          ..onPause = subscription!.pause
          ..onResume = subscription!.resume;
      }
    };
    controller.onCancel = () {
      final toCancel = subscription;
      subscription = null;
      return toCancel?.cancel();
    };

    return controller.stream;
  }
}

/// Extends the Stream class with the ability to transform a stream
/// in single emission stream
extension ToSingleExtension<T> on Stream<T> {
  /// Transform a [Stream] that should output a single value or a single error
  /// to a [Single] stream
  Single<T> asSingle() => Single.fromStream(this);
}

/// Defines the breach of contract error for the [Single] stream class
class SingleError {
  /// Contains the breach of contract
  final String message;

  /// Contains the data that has violated the contract
  final Object? data;

  /// Contains the error that has violated the contract
  final ErrorAndStackTrace? error;

  /// Define the breach of contract
  SingleError(this.message, {this.data, this.error});

  @override
  String toString() => '$runtimeType\n$message\n${data ?? ''}${error ?? ''}';
}
