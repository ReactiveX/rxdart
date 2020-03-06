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

class OnListenStreamEvent<T> {
  final bool isOnListenEvent;
  final T event;

  OnListenStreamEvent.forOnListen()
      : isOnListenEvent = true,
        event = null;

  OnListenStreamEvent.forOnData(T data)
      : isOnListenEvent = false,
        event = data;
}
