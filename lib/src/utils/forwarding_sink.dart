import 'dart:async';

/// A [Sink] that supports event hooks.
///
/// This makes it suitable for certain rx transformers that need to
/// take action after onListen, onPause, onResume or onCancel.
///
/// The [ForwardingSink] has been designed to handle asynchronous events from
/// [Stream]s. See, for example, [Stream.eventTransformed] which uses
/// `EventSink`s to transform events.
abstract class ForwardingSink<T> implements EventSink<T> {
  /// Fires when a listener subscribes on the underlying [Stream].
  void onListen(EventSink<T> sink);

  /// Fires when a subscriber pauses.
  void onPause(EventSink<T> sink, [Future resumeSignal]);

  /// Fires when a subscriber resumes after a pause.
  void onResume(EventSink<T> sink);

  /// Fires when a subscriber cancels.
  FutureOr onCancel(EventSink<T> sink);
}

/// Private class, used for [StreamTransformer]s which may need to keep adding
/// events to the [Sink], once the source [Stream] closes
abstract class SafeClose {
  /// Called before the actual [StreamController] close
  /// allows actions to finalize before really closing.
  Future safeClose();
}
