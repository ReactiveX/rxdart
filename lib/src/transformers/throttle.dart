import 'dart:async';

import 'package:rxdart/src/transformers/backpressure.dart';
import 'package:rxdart/src/transformers/utils.dart';

/// A StreamTransformer that emits only the first item emitted by the source
/// Stream during sequential time windows of a specified duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new ThrottleStreamTransformer(new Duration(seconds: 1)))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  ThrottleStreamTransformer(Stream window(T event))
      : transformer = _buildTransformer(window) {
    assert(window != null, 'window stream factory cannot be null');
  }

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Stream window(T event)) =>
      streamTransformed(_setupBackpressure(window));

  static BackpressureStreamTransformer<T, T> _setupBackpressure<T>(
          Stream window(T event)) =>
      BackpressureStreamTransformer(
          WindowStrategy.eventAfterLastWindow, window, (event) => event, null);
}
