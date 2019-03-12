import 'dart:async';

import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// A StreamTransformer that emits only the first item emitted by the source
/// Stream during sequential time windows of a specified duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new ThrottleStreamTransformer(new Duration(seconds: 1)))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> extends BackpressureStreamTransformer<T, T> {
  ThrottleStreamTransformer(Stream window(T event))
      : super(WindowStrategy.eventAfterLastWindow, window,
            onWindowStart: (event) => event) {
    assert(window != null, 'window stream factory cannot be null');
  }
}
