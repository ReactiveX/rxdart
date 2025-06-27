import 'dart:async';

import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// An interface that is similar to [EventSink] and [MultiStreamController], but with additional features.
/// See also [EventSink] and [MultiStreamController].
///
/// Acts like a normal asynchronous controller, but also allows
/// adding events synchronously.
/// As with any synchronous event delivery, the sender should be very careful
/// to not deliver events at times when a new listener might not
/// be ready to receive them.
/// That usually means only delivering events synchronously in response to other
/// asynchronous events, because that is a time when an asynchronous event could
/// happen.
abstract class EnhancedEventSink<T> {
  /// Whether the subscription would need to buffer events.
  bool get isPaused;

  /// Adds a data [event] to the sink.
  ///
  /// Must not be called on a closed sink.
  void add(T event);

  /// Adds and delivers an event.
  ///
  /// Adds an event like [add] and attempts to deliver it immediately.
  /// Delivery can be delayed if other previously added events are
  /// still pending delivery, if the subscription is paused,
  /// or if the subscription isn't listening yet.
  void addSync(T value);

  /// Adds and delivers an error event.
  ///
  /// Adds an error like [addErrorSync] and attempts to deliver it immediately.
  /// Delivery can be delayed if other previously added events are
  /// still pending delivery, if the subscription is paused,
  /// or if the subscription isn't listening yet.
  void addErrorSync(Object error, StackTrace? stackTrace);

  /// Closes the controller and delivers a done event.
  ///
  /// Closes the controller like [closeSync] and attempts to deliver a "done"
  /// event immediately.
  /// Delivery can be delayed if other previously added events are
  /// still pending delivery, if the subscription is paused,
  /// or if the subscription isn't listening yet.
  /// If it's necessary to know whether the "done" event has been delivered,
  /// [done] future will complete when that has happened.
  void closeSync();
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

  /// ----------------------------- Lifecycle -----------------------------

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
