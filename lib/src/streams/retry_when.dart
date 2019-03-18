import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

/// Creates a Stream that will recreate and re-listen to the source
/// Stream when the notifier emits a new value. If the source Stream
/// emits an error or it completes, the Stream terminates.
///
/// If the [retryWhenFactory] emits an error a [RetryError] will be
/// thrown. The RetryError will contain all of the [Error]s and
/// [StackTrace]s that caused the failure.
///
/// ### Basic Example
/// ```dart
/// new RetryWhenStream<int>(
///   () => new Stream<int>.fromIterable(<int>[1]),
///   (dynamic error, StackTrace s) => throw error,
/// ).listen(print); // Prints 1
/// ```
///
/// ### Periodic Example
/// ```dart
/// new RetryWhenStream<int>(
///   () => new Observable<int>
///       .periodic(const Duration(seconds: 1), (int i) => i)
///       .map((int i) => i == 2 ? throw 'exception' : i),
///   (dynamic e, StackTrace s) {
///     return new Observable<String>
///         .timer('random value', const Duration(milliseconds: 200));
///   },
/// ).take(4).listen(print); // Prints 0, 1, 0, 1
/// ```
///
/// ### Complex Example
/// ```dart
/// bool errorHappened = false;
/// new RetryWhenStream(
///   () => new Observable
///       .periodic(const Duration(seconds: 1), (i) => i)
///       .map((i) {
///         if (i == 3 && !errorHappened) {
///           throw 'We can take this. Please restart.';
///         } else if (i == 4) {
///           throw 'It\'s enough.';
///         } else {
///           return i;
///         }
///       }),
///   (e, s) {
///     errorHappened = true;
///     if (e == 'We can take this. Please restart.') {
///       return new Observable.just('Ok. Here you go!');
///     } else {
///       return new Observable.error(e);
///     }
///   },
/// ).listen(
///   print,
///   onError: (e, s) => print(e),
/// ); // Prints 0, 1, 2, 0, 1, 2, 3, RetryError
/// ```
class RetryWhenStream<T> extends Stream<T> {
  final Stream<T> Function() streamFactory;
  final RetryWhenStreamFactory retryWhenFactory;
  StreamController<T> controller;
  StreamSubscription<T> subscription;
  List<ErrorAndStacktrace> _errors = <ErrorAndStacktrace>[];

  RetryWhenStream(this.streamFactory, this.retryWhenFactory);

  @override
  StreamSubscription<T> listen(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    controller ??= StreamController<T>(
      sync: true,
      onListen: _retry,
      onPause: ([Future<dynamic> resumeSignal]) =>
          subscription.pause(resumeSignal),
      onResume: () => subscription.resume(),
      onCancel: () => subscription.cancel(),
    );

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void _retry() {
    subscription = streamFactory().listen(
      controller.add,
      onError: (Object e, [StackTrace s]) {
        subscription.cancel();

        StreamSubscription<void> sub;
        sub = retryWhenFactory(e, s).listen(
          (event) {
            sub.cancel();
            _errors.add(ErrorAndStacktrace(e, s));
            _retry();
          },
          onError: (Object e, [StackTrace s]) {
            sub.cancel();
            controller
              ..addError(RetryError.onReviveFailed(
                _errors..add(ErrorAndStacktrace(e, s)),
              ))
              ..close();
          },
        );
      },
      onDone: controller.close,
      cancelOnError: false,
    );
  }
}
