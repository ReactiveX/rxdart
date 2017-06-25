import 'dart:async';

/// A StreamTransformer that emits when the source stream emits, combining
/// the latest values from the two streams using the provided function.
///
/// If the latestFromStream has not emitted any values, this stream will not
/// emit either.
///
/// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
///
/// ### Example
///
///     new Stream.fromIterable([1, 2]).transform(
///       new WithLatestFromStreamTransformer(
///         new Stream.fromIterable([2, 3]), (a, b) => a + b)
///       .listen(print); // prints 4 (due to the async nature of streams)
class WithLatestFromStreamTransformer<T, S, R>
    implements StreamTransformer<T, R> {
  final StreamTransformer<T, R> transformer;

  WithLatestFromStreamTransformer(Stream<S> latestFromStream, R fn(T t, S s))
      : transformer = _buildTransformer(latestFromStream, fn);

  @override
  Stream<R> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, R> _buildTransformer<T, S, R>(
      Stream<S> latestFromStream, R fn(T t, S s)) {
    if (latestFromStream == null) {
      throw new ArgumentError('latestFromStream cannot be null');
    } else if (fn == null) {
      throw new ArgumentError('combiner cannot be null');
    }

    return new StreamTransformer<T, R>((Stream<T> input, bool cancelOnError) {
      StreamController<R> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> latestFromSubscription;
      S latestValue;

      controller = new StreamController<R>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              if (latestValue != null) {
                  try {
                    controller.add(fn(value, latestValue));
                  } catch (e, s) {
                    controller.addError(e, s);
                }
              }
            }, onError: controller.addError);

            latestFromSubscription = latestFromStream.listen((S latest) {
              latestValue = latest;
            },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () {
            return Future.wait(<Future<dynamic>>[
              subscription.cancel(),
              latestFromSubscription.cancel()
            ].where((Future<dynamic> cancelFuture) => cancelFuture != null));
          });

      return controller.stream.listen(null);
    });
  }
}
