import 'package:rxdart/src/observable.dart';

class StartWithManyObservable<T> extends Observable<T> {
  StartWithManyObservable(Stream<T> stream, List<T> startValues)
      : super(buildStream(stream, startValues));

  static Stream<T> buildStream<T>(Stream<T> stream, List<T> startValues) {
    return stream.transform(
        new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            startValues.forEach(controller.add);

            subscription = input.listen(controller.add,
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    }));
  }
}
