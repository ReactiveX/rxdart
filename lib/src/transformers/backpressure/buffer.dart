import 'dart:async';

import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// Creates an Observable where each item is a [List] containing the items
/// from the source sequence, batched by the [sampler].
///
/// ### Example with [onCount]
///
///     Observable.range(1, 4)
///       .buffer(onCount(2))
///       .listen(print); // prints [1, 2], [3, 4]
///
/// ### Example with [onFuture]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onFuture(() => new Future.delayed(const Duration(milliseconds: 220))))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
///
/// ### Example with [onTest]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onTest((i) => i % 2 == 0))
///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
///
/// ### Example with [onTime]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onTime(const Duration(milliseconds: 220)))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
///
/// ### Example with [onStream]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .buffer(onStream(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i)))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
///
/// You can create your own sampler by extending [StreamView]
/// should the above samplers be insufficient for your use case.
class BufferStreamTransformer<T>
    extends BackpressureStreamTransformer<T, List<T>> {
  BufferStreamTransformer(Stream window(T event))
      : super(WindowStrategy.firstEventOnly, window,
            onWindowEnd: (List<T> queue) => queue, ignoreEmptyWindows: false) {
    if (window == null) throw new ArgumentError.notNull('window');
  }
}

class BufferCountStreamTransformer<T>
    extends BackpressureStreamTransformer<T, List<T>> {
  BufferCountStreamTransformer(int count, [int startBufferEvery = 0])
      : super(WindowStrategy.never, null,
            onWindowEnd: (List<T> queue) => queue,
            startBufferEvery: startBufferEvery,
            closeWindowWhen: (Iterable<T> queue) => queue.length == count) {
    if (count == null) throw new ArgumentError.notNull('count');
    if (startBufferEvery == null)
      throw new ArgumentError.notNull('startBufferEvery');
    if (count < 1) throw new ArgumentError.value(count, 'count');
    if (startBufferEvery < 0)
      throw new ArgumentError.value(startBufferEvery, 'startBufferEvery');
  }
}

class BufferTestStreamTransformer<T>
    extends BackpressureStreamTransformer<T, List<T>> {
  BufferTestStreamTransformer(bool test(T value))
      : super(WindowStrategy.never, null,
            onWindowEnd: (List<T> queue) => queue,
            closeWindowWhen: (Iterable<T> queue) => test(queue.last)) {
    if (test == null) throw new ArgumentError.notNull('test');
  }
}
