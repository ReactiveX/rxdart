import 'dart:async';

/// A [Sink] that supports event hooks.
///
/// This makes it suitable for certain rx transformers that need to
/// take action after onListen, onPause, onResume or onCancel.
///
/// The [ForwardingSink] has been designed to handle asynchronous events from
/// [Stream]s. See, for example, [Stream.eventTransformed] which uses
/// `EventSink`s to transform events.
abstract class ForwardingSink<T, R> {
  /// Handle data event
  void add(EventSink<R> sink, T data);

  /// Handle error event
  void addError(EventSink<R> sink, Object error, [StackTrace? st]);

  /// Handle close event
  void close(EventSink<R> sink);

  /// Fires when a listener subscribes on the underlying [Stream].
  void onListen(EventSink<R> sink);

  /// Fires when a subscriber pauses.
  void onPause(EventSink<R> sink);

  /// Fires when a subscriber resumes after a pause.
  void onResume(EventSink<R> sink);

  /// Fires when a subscriber cancels.
  FutureOr onCancel(EventSink<R> sink);
}

/// This [ForwardingSink] mixin implements all [ForwardingSink] members except [add].
mixin ForwardingSinkMixin<T, R> implements ForwardingSink<T, R> {
  @override
  FutureOr<void> onCancel(EventSink<R> sink) {}

  @override
  void onPause(EventSink<R> sink) {}

  @override
  void onResume(EventSink<R> sink) {}

  @override
  void onListen(EventSink<R> sink) {}

  @override
  void add(EventSink<R> sink, T data);

  @override
  void addError(EventSink<R> sink, Object error, [StackTrace? st]) =>
      sink.addError(error, st);

  @override
  void close(EventSink<R> sink) => sink.close();
}
