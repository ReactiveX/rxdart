import 'package:rxdart/src/observable/stream.dart';

class SampleObservable<T> extends StreamObservable<T> {
  SampleObservable(Stream<T> stream, Stream<dynamic> sampleStream)
      : super(buildStream<T>(stream, sampleStream));

  static Stream<T> buildStream<T>(
      Stream<T> stream, Stream<dynamic> sampleStream) {
    return stream.transform(
        new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<dynamic> sampleSubscription;
      T currentValue;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              currentValue = value;
            }, onError: controller.addError);

            sampleSubscription = sampleStream.listen((_) {
              if (currentValue != null) controller.add(currentValue);
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
              sampleSubscription.cancel()
            ].where((Future<dynamic> cancelFuture) => cancelFuture != null));
          });

      return controller.stream.listen(null);
    }));
  }
}
