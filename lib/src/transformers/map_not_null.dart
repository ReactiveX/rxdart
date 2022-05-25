import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _MapNotNullSink<T, R extends Object> extends ForwardingSink<T, R> {
  final R? Function(T) transform;

  _MapNotNullSink(this.transform);

  @override
  void onData(T data) {
    final value = transform(data);
    if (value != null) {
      sink.add(value);
    }
  }

  @override
  void onDone() => sink.close();

  @override
  void onError(Object error, StackTrace st) => sink.addError(error, st);

  @override
  FutureOr<void> onListen() {}

  @override
  FutureOr<void> onCancel() {}

  @override
  void onPause() {}

  @override
  void onResume() {}
}

/// Create a Stream containing only the non-`null` results
/// of applying the given [transform] function to each element of the Stream.
///
/// ### Example
///
///     Stream.fromIterable(['1', 'two', '3', 'four'])
///       .transform(MapNotNullStreamTransformer(int.tryParse))
///       .listen(print); // prints 1, 3
///
///     // equivalent to:
///
///     Stream.fromIterable(['1', 'two', '3', 'four'])
///       .map(int.tryParse)
///       .transform(WhereTypeStreamTransformer<int?, int>())
///       .listen(print); // prints 1, 3
class MapNotNullStreamTransformer<T, R extends Object>
    extends StreamTransformerBase<T, R> {
  /// A function that transforms each elements of the Stream.
  final R? Function(T) transform;

  /// Constructs a [StreamTransformer] which emits non-`null` elements
  /// of applying the given [transform] function to each element of the Stream.
  const MapNotNullStreamTransformer(this.transform);

  @override
  Stream<R> bind(Stream<T> stream) =>
      forwardStream(stream, () => _MapNotNullSink<T, R>(transform));
}

/// Extends the Stream class with the ability to convert the source Stream
/// to a Stream containing only the non-`null` results
/// of applying the given [transform] function to each element of this Stream.
extension MapNotNullExtension<T> on Stream<T> {
  /// Returns a Stream containing only the non-`null` results
  /// of applying the given [transform] function to each element of this Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable(['1', 'two', '3', 'four'])
  ///       .mapNotNull(int.tryParse)
  ///       .listen(print); // prints 1, 3
  ///
  ///     // equivalent to:
  ///
  ///     Stream.fromIterable(['1', 'two', '3', 'four'])
  ///       .map(int.tryParse)
  ///       .whereType<int>()
  ///       .listen(print); // prints 1, 3
  Stream<R> mapNotNull<R extends Object>(R? Function(T) transform) =>
      MapNotNullStreamTransformer<T, R>(transform).bind(this);
}
