import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _WhereNotNullStreamSink<T extends Object> extends ForwardingSink<T?, T> {
  @override
  void onData(T? data) {
    if (data != null) {
      sink.add(data);
    }
  }

  @override
  FutureOr<void> onCancel() {}

  @override
  void onDone() => sink.close();

  @override
  void onError(Object error, StackTrace st) => sink.addError(error, st);

  @override
  FutureOr<void> onListen() {}

  @override
  void onPause() {}

  @override
  void onResume() {}
}

/// Create a Stream which emits all the non-`null` elements of the Stream,
/// in their original emission order.
///
/// ### Example
///
///     Stream.fromIterable(<int?>[1, 2, 3, null, 4, null])
///       .transform(WhereNotNullStreamTransformer())
///       .listen(print); // prints 1, 2, 3, 4
///
///     // equivalent to:
///
///     Stream.fromIterable(<int?>[1, 2, 3, null, 4, null])
///       .transform(WhereTypeStreamTransformer<int?, int>())
///       .listen(print); // prints 1, 2, 3, 4
class WhereNotNullStreamTransformer<T extends Object>
    extends StreamTransformerBase<T?, T> {
  @override
  Stream<T> bind(Stream<T?> stream) =>
      forwardStream(stream, () => _WhereNotNullStreamSink<T>());
}

/// Extends the Stream class with the ability to convert the source Stream
/// to a Stream which emits all the non-`null` elements
/// of this Stream, in their original emission order.
extension WhereNotNullExtension<T extends Object> on Stream<T?> {
  /// Returns a Stream which emits all the non-`null` elements
  /// of this Stream, in their original emission order.
  ///
  /// For a `Stream<T?>`, this method is equivalent to `.whereType<T>()`.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable(<int?>[1, 2, 3, null, 4, null])
  ///       .whereNotNull()
  ///       .listen(print); // prints 1, 2, 3, 4
  ///
  ///     // equivalent to:
  ///
  ///     Stream.fromIterable(<int?>[1, 2, 3, null, 4, null])
  ///       .whereType<int>()
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<T> whereNotNull() => transform(WhereNotNullStreamTransformer<T>());
}
