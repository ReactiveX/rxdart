import 'dart:async';

/// Starts emitting items only after the given stream emits an item.
///
/// ### Example
///
///     new MergeStream([
///       new Observable.just(1),
///       new TimerStream(2, new Duration(minutes: 2))
///     ])
///     .transform(skipUntilTransformer(new TimerStream(1, new Duration(minutes: 1))))
///     .listen(print); // prints 2;
class SkipUntilStreamTransformer<T, S> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  SkipUntilStreamTransformer(Stream<S> otherStream)
      : transformer = _buildTransformer(otherStream);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T, S>(
      Stream<S> otherStream) {
    if (otherStream == null) {
      throw new ArgumentError('otherStream cannot be null');
    }

    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<S> otherSubscription;
      bool goTime = false;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((T data) {
              if (goTime) {
                controller.add(data);
              }
            },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);

            otherSubscription = otherStream.listen((_) {
              goTime = true;

              otherSubscription.cancel();
            }, onError: controller.addError, cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () {
            return Future.wait(<Future<dynamic>>[
              subscription.cancel(),
              otherSubscription.cancel()
            ].where((Future<dynamic> cancelFuture) => cancelFuture != null));
          });

      return controller.stream.listen(null);
    });
  }
}
