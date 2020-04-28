import 'dart:async';

import 'package:rxdart/src/streams/timer.dart';
import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// A [StreamTransformer] that emits only the first item emitted by the source
/// [Stream] while the window [Stream] is open.
///
/// if trailing is true, then the last item is emitted instead
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3])
///       .transform(ThrottleStreamTransformer((_) => TimerStream(true, const Duration(seconds: 1))))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> extends BackpressureStreamTransformer<T, T> {
  /// A [StreamTransformer] that emits only the first item emitted by the source
  /// [Stream] while [window] is open.
  ///
  /// if trailing is true, then the last item is emitted instead
  ThrottleStreamTransformer(
    Stream Function(T event) window, {
    bool trailing = false,
  }) : super(WindowStrategy.eventAfterLastWindow, window,
            onWindowStart: trailing ? null : (event) => event,
            onWindowEnd: trailing ? (Iterable<T> queue) => queue.last : null,
            dispatchOnClose: trailing) {
    assert(window != null, 'window stream factory cannot be null');
  }
}

/// Extends the Stream class with the ability to throttle events in various ways
extension ThrottleExtensions<T> on Stream<T> {
  /// Emits only the first item emitted by the source [Stream] while [window] is
  /// open.
  ///
  /// if [trailing] is true, then the last item is emitted instead
  ///
  /// You can use the value of the last throttled event to determine the length
  /// of the next [window].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .throttle((_) => TimerStream(true, Duration(seconds: 1)))
  Stream<T> throttle(Stream Function(T event) window,
          {bool trailing = false}) =>
      transform(ThrottleStreamTransformer<T>(window, trailing: trailing));

  /// Emits only the first item emitted by the source [Stream] within a time
  /// span of [duration].
  ///
  /// if [trailing] is true, then the last item is emitted instead
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .throttleTime(Duration(seconds: 1))
  Stream<T> throttleTime(Duration duration, {bool trailing = false}) {
    ArgumentError.checkNotNull(duration, 'duration');
    return transform(
      ThrottleStreamTransformer<T>(
        (_) => TimerStream<bool>(true, duration),
        trailing: trailing,
      ),
    );
  }
}
