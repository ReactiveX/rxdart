import 'dart:async';

import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// A enhanced [EventSink] that allows to check if the sink is paused.
abstract class EnhancedEventSink<T> implements EventSink<T> {
  /// Whether the subscription would need to buffer events.
  bool get isPaused;
}

/// A [Sink] that supports event hooks.
///
/// This makes it suitable for certain rx transformers that need to
/// take action after onListen, onPause, onResume or onCancel.
///
/// The [ForwardingSink] has been designed to handle asynchronous events from
/// [Stream]s. See, for example, [Stream.eventTransformed] which uses
/// `EventSink`s to transform events.
abstract class ForwardingSink<T, R> {
  EnhancedEventSink<R>? _sink;
  StreamSubscription<T>? _subscription;

  /// The output sink.
  /// @nonVirtual
  /// @internal
  EnhancedEventSink<R> get sink =>
      _sink ?? (throw StateError('Must call setSink(sink) before accessing!'));

  /// Set the output sink.
  /// @nonVirtual
  /// @internal
  void setSink(EnhancedEventSink<R> sink) => _sink = sink;

  /// Set the upstream subscription
  /// @nonVirtual
  /// @internal
  void setSubscription(StreamSubscription<T>? subscription) =>
      _subscription = subscription;

  /// --------------------------------------------------------------------------

  /// Pause the upstream subscription.
  /// @nonVirtual
  void pauseSubscription() => _subscription?.pause();

  /// Resume the upstream subscription.
  /// @nonVirtual
  void resumeSubscription() => _subscription?.resume();

  /// --------------------------------------------------------------------------

  /// Handle data event
  void onData(T data);

  /// Handle error event
  void onError(Object error, StackTrace st);

  /// Handle close event
  void onDone();

  /// Fires when a listener subscribes on the underlying [Stream].
  /// Returns a [Future] to delay listening to source [Stream].
  FutureOr<void> onListen();

  /// Fires when a subscriber pauses.
  void onPause();

  /// Fires when a subscriber resumes after a pause.
  void onResume();

  /// Fires when a subscriber cancels.
  FutureOr<void> onCancel();
}

/// @internal
/// @nodoc
extension EventSinkExtension<T> on EventSink<T> {
  /// @internal
  /// @nodoc
  void addErrorAndStackTrace(ErrorAndStackTrace errorAndSt) =>
      addError(errorAndSt.error, errorAndSt.stackTrace);
}
