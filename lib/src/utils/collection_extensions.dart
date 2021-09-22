import 'dart:collection';

/// Provides [mapNotNull] extension method on [Iterable].
extension MapNotNullIterableExtension<T> on Iterable<T> {
  /// The non-`null` results of calling [transform] on the elements of [this].
  ///
  /// Returns a lazy iterable which calls [transform]
  /// on the elements of this iterable in iteration order,
  /// then emits only the non-`null` values.
  ///
  /// If [transform] throws, the iteration is terminated.
  Iterable<R> mapNotNull<R>(R? Function(T) transform) sync* {
    for (final e in this) {
      final v = transform(e);
      if (v != null) {
        yield v;
      }
    }
  }
}

/// Provides [removeFirstElements] extension method on [Queue].
extension RemoveFirstElementsQueueExtension<T> on Queue<T> {
  /// Removes the first [count] elements of this queue.
  void removeFirstElements(int count) {
    for (var i = 0; i < count; i++) {
      removeFirst();
    }
  }
}
