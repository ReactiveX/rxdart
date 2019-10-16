import 'dart:async';

extension ObservableExtensions<T> on Stream<T> {
  /// Maps each emitted item to a new [Stream] using the given mapper, then
  /// subscribes to each new stream one after the next until all values are
  /// emitted.
  ///
  /// ConcatMap is similar to flatMap, but ensures order by guaranteeing that
  /// all items from the created stream will be emitted before moving to the
  /// next created stream. This process continues until all created streams have
  /// completed.
  ///
  /// This is a simple alias for Dart Stream's `asyncExpand`, but is included to
  /// ensure a more consistent Rx API.
  ///
  /// ### Example
  ///
  ///     Observable.range(4, 1)
  ///       .concatMap((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 4, 3, 2, 1
  @Deprecated('Use the asyncExpand method included with the core Stream api')
  Stream<S> concatMap<S>(Stream<S> mapper(T value)) => asyncExpand(mapper);

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
