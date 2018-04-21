import 'dart:async';

import 'package:rxdart/src/futures/wrapped_future.dart';

/// Converts a Stream into a Future that completes with the smallest item
/// emitted by the Stream.
///
/// This is similar to finding the min value in a list, but the values are
/// asynchronous.
///
/// ### Example
///
///     int min = await new StreamMinFuture(new Stream.fromIterable([1, 2, 3]));
///
///     print(min); // prints 1
///
/// ### Example with custom [Comparator]
///
///     Stream<String> stream = new Stream.fromIterable("short", "loooooooong");
///     Comparator<String> stringLengthComparator = (a, b) => a.length - b.length;
///     String min = await new StreamMinFuture(stream, stringLengthComparator);
///
///     print(min); // prints "short"
class StreamMinFuture<T> extends WrappedFuture<T> {
  StreamMinFuture(Stream<T> stream, [Comparator<T> comparator])
      : super(stream
            .toList()
            .then((List<T> values) => (values..sort(comparator)).first));
}
