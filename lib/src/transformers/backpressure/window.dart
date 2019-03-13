import 'dart:async';

import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// Creates an Observable where each item is a [Stream] containing the items
/// from the source sequence.
///
/// This [List] is emitted every time the window [Stream]
/// emits an event.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (i) => i)
///       .window(new Stream.periodic(const Duration(milliseconds: 160), (i) => i))
///       .asyncMap((stream) => stream.toList())
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class WindowStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Stream<T>> {
  WindowStreamTransformer(Stream window(T event))
      : super(WindowStrategy.firstEventOnly, window,
            onWindowEnd: (List<T> queue) => Stream.fromIterable(queue),
            ignoreEmptyWindows: false) {
    if (window == null) throw ArgumentError.notNull('window');
  }
}

/// Buffers a number of values from the source Observable by count then
/// emits the buffer as a [Stream] and clears it, and starts a new buffer each
/// startBufferEvery values. If startBufferEvery is not provided,
/// then new buffers are started immediately at the start of the source
/// and when each buffer closes and is emitted.
///
/// ### Example
/// count is the maximum size of the buffer emitted
///
///     Observable.range(1, 4)
///       .windowCount(2)
///       .asyncMap((stream) => stream.toList())
///       .listen(print); // prints [1, 2], [3, 4] done!
///
/// ### Example
/// if startBufferEvery is 2, then a new buffer will be started
/// on every other value from the source. A new buffer is started at the
/// beginning of the source by default.
///
///     Observable.range(1, 5)
///       .bufferCount(3, 2)
///       .listen(print); // prints [1, 2, 3], [3, 4, 5], [5] done!
class WindowCountStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Stream<T>> {
  WindowCountStreamTransformer(int count, [int startBufferEvery = 0])
      : super(WindowStrategy.onHandler, null,
            onWindowEnd: (List<T> queue) => Stream.fromIterable(queue),
            startBufferEvery: startBufferEvery,
            closeWindowWhen: (Iterable<T> queue) => queue.length == count) {
    if (count == null) throw ArgumentError.notNull('count');
    if (startBufferEvery == null)
      throw ArgumentError.notNull('startBufferEvery');
    if (count < 1) throw ArgumentError.value(count, 'count');
    if (startBufferEvery < 0)
      throw ArgumentError.value(startBufferEvery, 'startBufferEvery');
  }
}

/// Creates an Observable where each item is a [Stream] containing the items
/// from the source sequence, batched whenever test passes.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .windowTest((i) => i % 2 == 0)
///       .asyncMap((stream) => stream.toList())
///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
class WindowTestStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Stream<T>> {
  WindowTestStreamTransformer(bool test(T value))
      : super(WindowStrategy.onHandler, null,
            onWindowEnd: (List<T> queue) => Stream.fromIterable(queue),
            closeWindowWhen: (Iterable<T> queue) => test(queue.last)) {
    if (test == null) throw ArgumentError.notNull('test');
  }
}
