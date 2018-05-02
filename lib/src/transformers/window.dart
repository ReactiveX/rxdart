import 'dart:async';

import 'package:rxdart/src/samplers/buffer_strategy.dart';
import 'package:rxdart/src/transformers/do.dart';

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
class WindowStreamTransformer<T> extends StreamTransformerBase<T, Stream<T>> {
  final SamplerBuilder<T, Stream<T>> sampler;

  WindowStreamTransformer(this.sampler);

  @override
  Stream<Stream<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(sampler).bind(stream);

  static StreamTransformer<T, Stream<T>> _buildTransformer<T>(
      SamplerBuilder<T, Stream<T>> scheduler) {
    assertSampler(scheduler);

    return new StreamTransformer<T, Stream<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<Stream<T>> controller;
      StreamSubscription<Stream<T>> subscription;
      List<T> buffer = <T>[];

      void onDone() {
        if (controller.isClosed) return;

        if (buffer.isNotEmpty)
          controller.add(new Stream<T>.fromIterable(buffer));

        controller.close();
      }

      controller = new StreamController<Stream<T>>(
          sync: true,
          onListen: () {
            try {
              subscription = scheduler(
                  input.transform(new DoStreamTransformer<T>(onDone: onDone)),
                  (T data, EventSink<Stream<T>> sink, [int skip]) {
                buffer.add(data);
                sink.add(new Stream<T>.fromIterable(buffer));
              }, (_, EventSink<Stream<T>> sink, [int skip]) {
                sink.add(new Stream<T>.fromIterable(buffer));
                buffer = buffer.sublist(buffer.length - (skip ?? 0));
              }).listen(controller.add,
                  onError: controller.addError,
                  onDone: onDone,
                  cancelOnError: cancelOnError);
            } catch (e, s) {
              controller.addError(e, s);
            }
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }

  static void assertSampler<T>(SamplerBuilder<T, Stream<T>> scheduler) {
    if (scheduler == null) {
      throw new ArgumentError('scheduler cannot be null');
    }
  }
}
