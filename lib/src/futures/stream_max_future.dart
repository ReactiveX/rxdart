import 'dart:async';

import 'package:rxdart/src/futures/wrapped_future.dart';

/// Converts a Stream into a Future that completes with the largest item emitted
/// by the Stream.
///
/// This is similar to finding the max value in a list, but the values are
/// asynchronous.
///
/// ### Example
///
///     int max = await new StreamMaxFuture(new Stream.fromIterable([1, 2, 3]));
///
///     print(max); // prints 3
///
/// ### Example with custom [Comparator]
///
///     Stream<String> stream = new Stream.fromIterable("short", "loooooooong");
///     Comparator<String> stringLengthComparator = (a, b) => a.length - b.length;
///     String max = await new StreamMaxFuture(stream, stringLengthComparator);
///
///     print(max); // prints "loooooooong"
class StreamMaxFuture<T> extends WrappedFuture<T> {
  StreamMaxFuture(Stream<T> stream, [Comparator<T> comparator])
      : super(stream
            .toList()
            .then((List<T> values) => (values..sort(comparator)).last));
}
