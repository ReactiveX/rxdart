import 'package:rxdart/src/observable/stream.dart';

class WithLatestFromObservable<T, S, R> extends StreamObservable<R> {
  WithLatestFromObservable(
      Stream<T> stream, Stream<S> latestFromStream, R fn(T t, S s)) {
    Stream<R> transformed = stream.transform(
        new StreamTransformer<T, R>((Stream<T> input, bool cancelOnError) {
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
    }));

    if (stream.isBroadcast) {
      setStream(transformed.asBroadcastStream());
    } else {
      setStream(transformed);
    }
  }
}
