import 'dart:async';

import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// A [StreamTransformer] that emits only the first item emitted by the source
/// [Stream] while the window [Stream] is open.
///
/// if trailing is true, then the last item is emitted instead
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new ThrottleStreamTransformer((_) => TimerStream(true, const Duration(seconds: 1))))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> extends BackpressureStreamTransformer<T, T> {
  ThrottleStreamTransformer(Stream window(T event), {bool trailing = false})
      : super(WindowStrategy.eventAfterLastWindow, window,
            onWindowStart: trailing ? null : (event) => event,
            onWindowEnd: trailing ? (Iterable<T> queue) => queue.last : null) {
    assert(window != null, 'window stream factory cannot be null');
  }
}
