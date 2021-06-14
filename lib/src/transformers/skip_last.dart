import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _SkipLastStreamSink<T> extends ForwardingSink<T, T> {
  _SkipLastStreamSink(this.count);

  final int count;
  final List<T> queue = <T>[];

  @override
  void add(EventSink<T> sink, T data) {
    queue.add(data);
  }

  @override
  void addError(EventSink<T> sink, Object e, [StackTrace? st]) =>
      sink.addError(e, st);

  @override
  void close(EventSink<T> sink) {
    final takeNum = queue.length - count >= 0 ? queue.length - count : 0;
    queue.take(takeNum).forEach(sink.add);
    sink.close();
  }

  @override
  FutureOr onCancel(EventSink<T> sink) {
    queue.clear();
  }

  @override
  void onListen(EventSink<T> sink) {}

  @override
  void onPause(EventSink<T> sink) {}

  @override
  void onResume(EventSink<T> sink) {}
}

/// Skip the last [count] items emitted by the source [Stream]
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3, 4, 5])
///       .transform(SkipLastStreamTransformer(3))
///       .listen(print); // prints 1, 2
class SkipLastStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// Constructs a [StreamTransformer] which skip the last [count] items
  /// emitted by the source [Stream]
  SkipLastStreamTransformer(this.count) {
    if (count < 0) throw ArgumentError.value(count, 'count');
  }

  /// The [count] of final items to skip.
  final int count;

  @override
  Stream<T> bind(Stream<T> stream) =>
      ForwardedStream(inner: stream, connectedSink: _SkipLastStreamSink(count));
}

/// Extends the Stream class with the ability to skip the last [count] items
/// emitted by the source [Stream]
extension SkipLastExtension<T> on Stream<T> {
  /// Starts emitting every items except last [count] items.
  /// This causes items to be delayed.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4, 5])
  ///       .skipLast(3)
  ///       .listen(print); // prints 1, 2
  Stream<T> skipLast(int count) =>
      transform(SkipLastStreamTransformer<T>(count));
}
