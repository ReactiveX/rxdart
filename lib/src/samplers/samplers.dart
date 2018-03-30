import 'dart:async';

typedef SamplerBloc<S> SamplerBlocBuilder<T, S>(Stream<T> stream,
    OnDataTransform<T, S> bufferHandler, OnDataTransform<S, S> scheduleHandler);

typedef void OnDataTransform<T, S>(T event, EventSink<S> sink, [int skip]);

abstract class SamplerBloc<T> {
  Stream<T> get state;
}
