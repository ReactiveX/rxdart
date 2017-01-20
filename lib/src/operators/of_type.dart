import 'package:rxdart/src/observable/stream.dart';

class OfTypeObservable<T, S> extends StreamObservable<S> {

  OfTypeObservable(Stream<T> stream, S predicate(T event)) {

    setStream(stream.transform(new StreamTransformer<T, S>(
            (Stream<T> input, bool cancelOnError) {
          StreamController<S> controller;
          StreamSubscription<T> subscription;

          controller = new StreamController<S>(sync: true,
              onListen: () {
                subscription = input.listen((T value) {
                  try {
                    S result = predicate(value);

                    if (result != null) controller.add(result);
                  } catch (e) {}
                },
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