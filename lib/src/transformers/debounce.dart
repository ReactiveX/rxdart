import 'dart:async';

import 'package:rxdart/src/transformers/backpressure.dart';
import 'package:rxdart/src/transformers/utils.dart';

/// Transforms a Stream so that will only emit items from the source sequence
/// if a particular time span has passed without the source sequence emitting
/// another item.
///
/// The Debounce Transformer filters out items emitted by the source Observable
/// that are rapidly followed by another emitted item.
///
/// [Interactive marble diagram](http://rxmarbles.com/#debounce)
///
/// ### Example
///
///     new Observable.fromIterable([1, 2, 3, 4])
///       .debounce(new Duration(seconds: 1))
///       .listen(print); // prints 4
class DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  DebounceStreamTransformer(Stream window(T event))
      : transformer = _buildTransformer(window) {
    assert(window != null, 'window stream factory cannot be null');
  }

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Stream window(T event)) =>
      streamTransformed(_setupBackpressure(window));

  static BackpressureStreamTransformer<T, T> _setupBackpressure<T>(
          Stream window(T event)) =>
      BackpressureStreamTransformer(WindowStrategy.everyEvent, window, null,
          (Iterable<T> queue) => queue.last);
}
