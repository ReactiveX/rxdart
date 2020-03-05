import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Returns the values from the source stream sequence until the other
/// stream sequence produces a value.
///
/// ### Example
///
///     MergeStream([
///         Stream.fromIterable([1]),
///         TimerStream(2, Duration(minutes: 1))
///       ])
///       .transform(TakeUntilStreamTransformer(
///         TimerStream(3, Duration(seconds: 10))))
///       .listen(print); // prints 1
class TakeUntilStreamTransformer<T, S> extends StreamTransformerBase<T, T> {
  /// The [Stream] which closes this [Stream] as soon as it emits an event.
  final Stream<S> otherStream;

  /// Constructs a [StreamTransformer] which emits events from the source [Stream],
  /// until [otherStream] fires.
  TakeUntilStreamTransformer(this.otherStream);

  @override
  Stream<T> bind(Stream<T> stream) {
    if (otherStream == null) {
      throw ArgumentError('take until stream cannot be null');
    }

    StreamController<T> controller;
    StreamSubscription<T> subscription;
    StreamSubscription<S> otherSubscription;

    void onDone() {
      if (controller.isClosed) return;

      controller.close();
    }

    controller = createController(stream,
        onListen: () {
          subscription = stream.listen(controller.add,
              onError: controller.addError, onDone: onDone);

          otherSubscription = otherStream.listen((_) => onDone(),
              onError: controller.addError, onDone: onDone);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () async {
          await otherSubscription?.cancel();
          await subscription?.cancel();
        });

    return controller.stream;
  }
}

/// Extends the Stream class with the ability receive events from the source
/// Stream until another Stream produces a value.
extension TakeUntilExtension<T> on Stream<T> {
  /// Returns the values from the source Stream sequence until the other Stream
  /// sequence produces a value.
  ///
  /// ### Example
  ///
  ///     MergeStream([
  ///         Stream.fromIterable([1]),
  ///         TimerStream(2, Duration(minutes: 1))
  ///       ])
  ///       .takeUntil(TimerStream(3, Duration(seconds: 10)))
  ///       .listen(print); // prints 1
  Stream<T> takeUntil<S>(Stream<S> otherStream) =>
      transform(TakeUntilStreamTransformer<T, S>(otherStream));
}
