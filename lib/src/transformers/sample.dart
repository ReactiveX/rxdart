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

  SampleStreamTransformer(Stream<dynamic> sampleStream,
      {bool sampleOnValueOnly = true})
      : transformer = _buildTransformer(sampleStream,
            sampleOnValueOnly: sampleOnValueOnly);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Stream<dynamic> sampleStream,
      {bool sampleOnValueOnly = true}) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription<dynamic> sampleSubscription;
      _EventWrapper<T> currentValue;

      void onDone() {
        if (controller.isClosed) return;

        if (currentValue != null) {
          controller.add(currentValue.event);
        }

        controller.close();
      }

      void onSample(dynamic _) {
        if (currentValue != null || !sampleOnValueOnly) {
          controller.add(currentValue?.event);
          currentValue = null;
        }
      }

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            try {
              subscription = input.listen((value) {
                currentValue = _EventWrapper(value);
              },
                  onError: controller.addError,
                  onDone: onDone,
                  cancelOnError: cancelOnError);

              sampleSubscription = sampleStream.listen(onSample,
                  onError: controller.addError,
                  onDone: onDone,
                  cancelOnError: cancelOnError);
            } catch (e, s) {
              controller.addError(e, s);
            }
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () async {
            await sampleSubscription.cancel();
            await subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}

/// Inner wrapper class.
/// Because the event can be of value null, checking on != null in the code
/// above is ambiguous.
/// If we wrap the event, then the inner value can safely be null.
class _EventWrapper<T> {
  final T event;

  _EventWrapper(this.event);
}
