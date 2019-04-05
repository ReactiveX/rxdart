import 'dart:async';

/// Creates a Stream that emits each item in the Stream after a given
/// duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new IntervalStreamTransformer(Duration(seconds: 1)))
///       .listen((i) => print("$i sec"); // prints 1 sec, 2 sec, 3 sec
class IntervalStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  IntervalStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) =>
      StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<T> subscription;
        Future<T> onInterval;

        final combinedWait = (Future<dynamic> resumeSignal) =>
            (resumeSignal != null && onInterval != null)
                ? Future.wait<dynamic>([onInterval, resumeSignal])
                : resumeSignal;

        controller = StreamController<T>(
            sync: true,
            onListen: () {
              subscription = input.listen((value) {
                try {
                  onInterval = Future.delayed(duration, () => value);

                  // no need to call combinedWait here,
                  // if the main subscription is paused, then
                  // there can never be an event in that pause time frame
                  subscription.pause(onInterval
                      .then(controller.add)
                      .whenComplete(() => onInterval = null));
                } catch (e, s) {
                  controller.addError(e, s);
                }
              },
                  onError: controller.addError,
                  onDone: controller.close,
                  cancelOnError: cancelOnError);
            },
            // await also onInterval, if it is active
            onPause: ([Future<dynamic> resumeSignal]) =>
                subscription.pause(combinedWait(resumeSignal)),
            onResume: () => subscription.resume(),
            onCancel: () => subscription.cancel());

        return controller.stream.listen(null);
      });
}
