import 'dart:async';

class WithLatestFromStreamTransformer<T, S, R> implements StreamTransformer<T, R> {
  final StreamTransformer<T, R> transformer;

  WithLatestFromStreamTransformer(Stream<S> latestFromStream, R fn(T t, S s))
      : transformer = _buildTransformer(latestFromStream, fn);

  @override
  Stream<R> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, R> _buildTransformer<T, S, R>(
      Stream<S> latestFromStream, R fn(T t, S s)) {
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
                controller.add(fn(value, latestValue));
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
