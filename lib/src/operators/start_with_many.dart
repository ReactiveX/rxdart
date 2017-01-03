import 'package:rxdart/src/observable/stream.dart';

class StartWithManyObservable<T> extends StreamObservable<T> {

  StartWithManyObservable(Stream<T> stream, List<T> startValues) {
    setStream(stream.transform(new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(sync: true,
          onListen: () {
            startValues.forEach(controller.add);

            subscription = input.listen(controller.add,
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) => subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    }
    )));
  }

}