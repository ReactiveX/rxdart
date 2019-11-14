import 'dart:async';

/// An extei
extension ObservableExtensions<T> on Stream<T> {
  /// Converts a Stream into a Future that completes with the largest item
  /// emitted by the Stream.
  ///
  /// This is similar to finding the max value in a list, but the values are
  /// asynchronous.
  ///
  /// ### Example
  ///
  ///     final max = await Stream.fromIterable([1, 2, 3]).max();
  ///
  ///     print(max); // prints 3
  ///
  /// ### Example with custom [Comparator]
  ///
  ///     final stream = Stream.fromIterable(["short", "looooooong"]);
  ///     final max = await stream.max((a, b) => a.length - b.length);
  ///
  ///     print(max); // prints "looooooong"
  Future<T> max([Comparator<T> comparator]) =>
      toList().then((List<T> values) => (values..sort(comparator)).last);

  /// Converts a Stream into a Future that completes with the smallest item
  /// emitted by the Stream.
  ///
  /// This is similar to finding the min value in a list, but the values are
  /// asynchronous!
  ///
  /// ### Example
  ///
  ///     final min = await Stream.fromIterable([1, 2, 3]).min();
  ///
  ///     print(min); // prints 1
  ///
  /// ### Example with custom [Comparator]
  ///
  ///     final stream = Stream.fromIterable(["short", "looooooong"]);
  ///     final min = await stream.min((a, b) => a.length - b.length);
  ///
  ///     print(min); // prints "short"
  Future<T> min([Comparator<T> comparator]) =>
      toList().then((List<T> values) => (values..sort(comparator)).first);
}
