import 'dart:async';

typedef void OnDataTransform<T, S>(T event, EventSink<S> sink, [int skip]);
