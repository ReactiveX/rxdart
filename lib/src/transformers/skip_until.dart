import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Starts emitting events only after the given stream emits an event.
///
/// ### Example
///
///     MergeStream([
///       Stream.value(1),
///       TimerStream(2, Duration(minutes: 2))
///     ])
///     .transform(skipUntilTransformer(TimerStream(1, Duration(minutes: 1))))
///     .listen(print); // prints 2;
class SkipUntilStreamTransformer<T, S> extends StreamTransformerBase<T, T> {
  /// The [Stream] which is required to emit first, before this [Stream] starts emitting
  final Stream<S> otherStream;

  /// Constructs a [StreamTransformer] which starts emitting events
  /// only after [otherStream] emits an event.
  SkipUntilStreamTransformer(this.otherStream);

  @override
  Stream<T> bind(Stream<T> stream) {
    if (otherStream == null) {
      throw ArgumentError('otherStream cannot be null');
    }

    StreamController<T> controller;
    StreamSubscription<T> subscription;
    StreamSubscription<S> otherSubscription;
    var goTime = false;

    void onDone() {
      if (controller.isClosed) return;

      controller.close();
    }

    controller = createController(stream,
        onListen: () {
          subscription = stream.listen((T data) {
            if (goTime) {
              controller.add(data);
            }
          }, onError: controller.addError, onDone: onDone);

          otherSubscription = otherStream.listen((_) {
            goTime = true;

            otherSubscription.cancel();
          }, onError: controller.addError, onDone: onDone);
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

/// Extends the Stream class with the ability to skip events until another
/// Stream emits an item.
extension SkipUntilExtension<T> on Stream<T> {
  /// Starts emitting items only after the given stream emits an item.
  ///
  /// ### Example
  ///
  ///     MergeStream([
  ///         Stream.fromIterable([1]),
  ///         TimerStream(2, Duration(minutes: 2))
  ///       ])
  ///       .skipUntil(TimerStream(true, Duration(minutes: 1)))
  ///       .listen(print); // prints 2;
  Stream<T> skipUntil<S>(Stream<S> otherStream) =>
      transform(SkipUntilStreamTransformer<T, S>(otherStream));
}
