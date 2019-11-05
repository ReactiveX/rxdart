import 'dart:async';

import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// Transforms a [Stream] so that will only emit items from the source sequence
/// if a window has completed, without the source sequence emitting
/// another item.
///
/// This window is created after the last debounced event was emitted.
/// You can use the value of the last debounced event to determine
/// the length of the next window.
///
/// A window is open until the first window event emits.
///
/// The debounce [StreamTransformer] filters out items
/// emitted by the source Observable
/// that are rapidly followed by another emitted item.
///
/// [Interactive marble diagram](http://rxmarbles.com/#debounce)
///
/// ### Example
///
///     new Observable.fromIterable([1, 2, 3, 4])
///       .debounceTime(new Duration(seconds: 1))
///       .listen(print); // prints 4
class DebounceStreamTransformer<T> extends BackpressureStreamTransformer<T, T> {
  /// Constructs a [StreamTransformer] which buffers events into a [List] and
  /// emits this [List] whenever the current [window] fires.
  ///
  /// The [window] is reset whenever the [Stream] that is being transformed
  /// emits an event.
  DebounceStreamTransformer(Stream window(T event))
      : super(WindowStrategy.everyEvent, window,
            onWindowEnd: (Iterable<T> queue) => queue.last) {
    assert(window != null, 'window stream factory cannot be null');
  }
}
