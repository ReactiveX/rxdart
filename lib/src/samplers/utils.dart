import 'dart:async';

typedef void OnDataTransform<T, S>(T event, EventSink<S> sink, [int skip]);

/// An abstraction layer used internally by some [StreamTransformer]s
///
/// The bloc must implement a constructor which primarily takes a [Stream]
/// from the [StreamTransformer], together with other values if required.
///
/// It then transforms the data, to finally return it to the [StreamTransformer]
/// via the [state] getter.
///
/// This is a generic interface that other bloc strategies can implement.
abstract class SamplerBloc<T> {
  Stream<T> get state;
}
