/// A special [Stream], which wraps events into [OnListenStreamEvent] events,
/// the [Stream] immediately dispatches an [OnListenStreamEvent] which
/// represents the onListen event when it is subscribed to.
///
/// This [Stream] is for internal use only, and used with transformers that
/// rely on the onListen event.
Stream<OnListenStreamEvent<T>> toOnListenEnabledStream<T>(Stream<T> stream) {
  final generator = () async* {
    yield OnListenStreamEvent<T>.forOnListen();
    yield* stream.map((data) => OnListenStreamEvent.forOnData(data));
  };
  final enabledStream = generator();

  if (stream.isBroadcast) {
    return enabledStream.asBroadcastStream();
  }

  return enabledStream;
}

/// A wrapper event,
/// the event is either an onListen notifier,
/// or an actual data event.
class OnListenStreamEvent<T> {
  /// flag which is true, if this event is an onListen event
  final bool isOnListenEvent;

  /// if it is a data event, then this value represents that data.
  final T event;

  /// Creates a new [OnListenStreamEvent], without event data but
  /// with the [isOnListenEvent] flag set to true.
  OnListenStreamEvent.forOnListen()
      : isOnListenEvent = true,
        event = null;

  /// Creates a new [OnListenStreamEvent], with event data and
  /// with the [isOnListenEvent] flag set to false.
  OnListenStreamEvent.forOnData(T data)
      : isOnListenEvent = false,
        event = data;
}
