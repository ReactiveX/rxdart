import 'dart:async';

import 'package:rxdart/src/transformers/backpressure.dart';
import 'package:rxdart/src/transformers/utils.dart';

/// A StreamTransformer that, when the specified sample stream emits
/// an item or completes, emits the most recently emitted item (if any)
/// emitted by the source stream since the previous emission from
/// the sample stream.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new SampleStreamTransformer(new TimerStream(1, new Duration(seconds: 1)))
///       .listen(print); // prints 3
class SampleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  SampleStreamTransformer(Stream window(T event))
      : transformer = _buildTransformer(window) {
    assert(window != null, 'window stream factory cannot be null');
  }

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Stream window(T event)) =>
      streamTransformed(_setupBackpressure(window));

  static BackpressureStreamTransformer<T, T> _setupBackpressure<T>(
          Stream window(T event)) =>
      BackpressureStreamTransformer(WindowStrategy.firstEventOnly, window, null,
          (Iterable<T> queue) => queue.last);
}
