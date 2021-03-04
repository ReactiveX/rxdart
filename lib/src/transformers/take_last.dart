import 'dart:async';
import 'dart:collection';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _TakeLastStreamSink<T> implements ForwardingSink<T, T> {
  _TakeLastStreamSink(this.count);

  final int count;
  final Queue<T> queue = DoubleLinkedQueue<T>();

  @override
  void add(EventSink<T> sink, T data) {
    if (count > 0) {
      queue.add(data);

      if (queue.length > count) {
        queue.removeFirstElements(queue.length - count);
      }
    }
  }

  @override
  void addError(EventSink<T> sink, Object e, StackTrace st) =>
      sink.addError(e, st);

  @override
  void close(EventSink<T> sink) {
    queue.forEach(sink.add);
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

/// Emits only the final [count] values emitted by the source [Stream].
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3, 4, 5])
///       .transform(TakeLastStreamTransformer(3))
///       .listen(print); // prints 3, 4, 5
class TakeLastStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// Constructs a [StreamTransformer] which emits only the final [count]
  /// events from the source [Stream].
  TakeLastStreamTransformer(this.count) {
    if (count < 0) throw ArgumentError.value(count, 'count');
  }

  /// The [count] of final items emitted when the stream completes.
  final int count;

  @override
  Stream<T> bind(Stream<T> stream) =>
      forwardStream(stream, _TakeLastStreamSink<T>(count));
}

/// Extends the [Stream] class with the ability receive only the final [count]
/// events from the source [Stream].
extension TakeLastExtension<T> on Stream<T> {
  /// Emits only the final [count] values emitted by the source [Stream].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4, 5])
  ///       .takeLast(3)
  ///       .listen(print); // prints 3, 4, 5
  Stream<T> takeLast(int count) =>
      transform(TakeLastStreamTransformer<T>(count));
}

extension _RemoveFirstNQueueExtension<T> on Queue<T> {
  /// Removes the first [count] elements of this queue.
  void removeFirstElements(int count) {
    for (var i = 0; i < count; i++) {
      removeFirst();
    }
  }
}
