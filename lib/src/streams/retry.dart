import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

/// Creates a Stream that will recreate and re-listen to the source
/// Stream the specified number of times until the Stream terminates
/// successfully.
///
/// If the retry count is not specified, it retries indefinitely. If the retry
/// count is met, but the Stream has not terminated successfully, a
/// `RetryError` will be thrown. The RetryError will contain all of the Errors
/// and StackTraces that caused the failure.
///
/// ### Example
///
///     new RetryStream(() { new Stream.fromIterable([1]); })
///         .listen((i) => print(i)); // Prints 1
///
///     new RetryStream(() {
///          new Stream.fromIterable([1])
///             .concatWith([new ErrorStream(new Error())]);
///        }, 1)
///        .listen(print, onError: (e, s) => print(e)); // Prints 1, 1, RetryError
class RetryStream<T> extends Stream<T> {
  final StreamFactory<T> streamFactory;
  int count;
  int retryStep = 0;
  StreamController<T> controller;
  StreamSubscription<T> subscription;
  bool _isUsed = false;
  List<ErrorAndStacktrace> _errors = <ErrorAndStacktrace>[];

  RetryStream(this.streamFactory, [this.count]);

  @override
  StreamSubscription<T> listen(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    if (_isUsed) throw StateError("Stream has already been listened to.");
    _isUsed = true;

    controller = StreamController<T>(
        sync: true,
        onListen: retry,
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void retry() {
    subscription = streamFactory().listen(controller.add,
        onError: (dynamic e, StackTrace s) {
      subscription.cancel();

      if (count == retryStep) {
        controller.addError(RetryError(
          'Received an error after attempting $count retries',
          _errors..add(ErrorAndStacktrace(e, s)),
        ));
        controller.close();
      } else {
        retryStep++;
        _errors.add(ErrorAndStacktrace(e, s));
        retry();
      }
    }, onDone: controller.close, cancelOnError: false);
  }
}
