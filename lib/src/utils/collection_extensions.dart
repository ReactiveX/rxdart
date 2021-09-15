import 'dart:collection';

/// TODO
extension MapNotNullIterableExtension<T> on Iterable<T> {
  /// TODO
  Iterable<R> mapNotNull<R>(R? Function(T) transform) sync* {
    for (final e in this) {
      final v = transform(e);
      if (v != null) {
        yield v;
      }
    }
  }
}

/// TODO
extension RemoveFirstElementsQueueExtension<T> on Queue<T> {
  /// Removes the first [count] elements of this queue.
  void removeFirstElements(int count) {
    for (var i = 0; i < count; i++) {
      removeFirst();
    }
  }
}
