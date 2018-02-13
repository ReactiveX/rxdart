import 'dart:async';

/// A StreamTransformer that, when the specified sample stream emits
/// an item or completes, emits the most recently emitted item (if any)
/// emitted by the source stream since the previous emission from
/// the sample stream.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new SampleStreamTransformer(new TimerStream(1, new Duration(seconds: 1)))
///       .listen(print); // prints 3
class SampleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  SampleStreamTransformer(Stream<dynamic> sampleStream)
      : transformer = _buildTransformer(sampleStream);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Stream<dynamic> sampleStream) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<dynamic> sampleSubscription;
      T currentValue;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            try {
              subscription = input.listen((T value) {
                currentValue = value;
              }, onError: controller.addError);

              sampleSubscription = sampleStream.listen(
                  (_) {
                    if (currentValue != null) {
                      controller.add(currentValue);
                      currentValue = null;
                    }
                  },
                  onError: controller.addError,
                  onDone: () {
                    if (currentValue != null) {
                      controller.add(currentValue);
                    }

                    controller.close();
                  },
                  cancelOnError: cancelOnError);
            } catch (e, s) {
              controller.addError(e, s);
            }
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
    });
  }
}
