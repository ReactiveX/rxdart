import 'dart:collection';
import 'dart:math';

/// @internal
/// @nodoc
/// Provides extension methods on [List].
extension ListExtensions<T> on List<T> {
  /// @internal
  /// Returns a list of values built from the elements of this list
  /// and the other list with the same index
  /// using the provided transform function applied to each pair of elements.
  /// The returned list has length of the shortest list.
  List<R> zipWith<R, S>(
    List<S> other,
    R Function(T, S) transform, {
    bool growable = true,
  }) =>
      List.generate(
        min(length, other.length),
        (index) => transform(this[index], other[index]),
        growable: growable,
      );
}

/// @internal
/// Provides extension methods on [Iterable].
extension IterableExtensions<T> on Iterable<T> {
  /// @internal
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

  /// @internal
  /// Maps each element and its index to a new value.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    var index = 0;
    for (final e in this) {
      yield transform(index++, e);
    }
  }
}

/// @internal
/// Provides [removeFirstElements] extension method on [Queue].
extension RemoveFirstElementsQueueExtension<T> on Queue<T> {
  /// @internal
  /// Removes the first [count] elements of this queue.
  void removeFirstElements(int count) {
    for (var i = 0; i < count; i++) {
      removeFirst();
    }
  }
}
