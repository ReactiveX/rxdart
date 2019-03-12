import 'dart:async';

import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// Creates an Observable where each item is a [Stream] containing the items
/// from the source sequence, batched by the [sampler].
///
/// ### Example with [onCount]
///
///     Observable.range(1, 4)
///       .window(onCount(2))
///       .doOnData((_) => print('next window'))
///       .flatMap((s) => s)
///       .listen(print); // prints next window 1, 2, next window 3, 4
///
/// ### Example with [onFuture]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .window(onFuture(() => new Future.delayed(const Duration(milliseconds: 220))))
///       .doOnData((_) => print('next window'))
///       .flatMap((s) => s)
///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
///
/// ### Example with [onTest]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .window(onTest((i) => i % 2 == 0))
///       .doOnData((_) => print('next window'))
///       .flatMap((s) => s)
///       .listen(print); // prints next window 0, next window 1, 2 next window 3, 4,  ...
///
/// ### Example with [onTime]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .window(onTime(const Duration(milliseconds: 220)))
///       .doOnData((_) => print('next window'))
///       .flatMap((s) => s)
///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
///
/// ### Example with [onStream]
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .window(onStream(new Stream.periodic(const Duration(milliseconds: 220), (int i) => i)))
///       .doOnData((_) => print('next window'))
///       .flatMap((s) => s)
///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
///
/// You can create your own sampler by extending [StreamView]
/// should the above samplers be insufficient for your use case.
class WindowStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Stream<T>> {
  WindowStreamTransformer(Stream window(T event))
      : super(WindowStrategy.firstEventOnly, window,
            onWindowEnd: (List<T> queue) => Stream.fromIterable(queue),
            ignoreEmptyWindows: false) {
    if (window == null) throw new ArgumentError.notNull('window');
  }
}

class WindowCountStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Stream<T>> {
  WindowCountStreamTransformer(int count, [int startBufferEvery = 0])
      : super(WindowStrategy.never, null,
            onWindowEnd: (List<T> queue) => Stream.fromIterable(queue),
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

class WindowTestStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Stream<T>> {
  WindowTestStreamTransformer(bool test(T value))
      : super(WindowStrategy.never, null,
            onWindowEnd: (List<T> queue) => Stream.fromIterable(queue),
            closeWindowWhen: (Iterable<T> queue) => test(queue.last)) {
    if (test == null) throw new ArgumentError.notNull('test');
  }
}
