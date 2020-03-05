import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Emit items from the source [Stream], or a single default item if the source
/// Stream emits nothing.
///
/// ### Example
///
///     Stream.empty()
///       .transform(DefaultIfEmptyStreamTransformer(10))
///       .listen(print); // prints 10
class DefaultIfEmptyStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// The event that should be emitted if the source [Stream] is empty
  final T defaultValue;

  /// Constructs a [StreamTransformer] which either emits from the source [Stream],
  /// or just a [defaultValue] if the source [Stream] emits nothing.
  DefaultIfEmptyStreamTransformer(this.defaultValue);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;
    var hasEvent = false;

    controller = createController(stream,
        onListen: () {
          subscription = stream.listen(
              (value) {
                hasEvent = true;
                try {
                  controller.add(value);
                } catch (e, s) {
                  controller.addError(e, s);
                }
              },
              onError: controller.addError,
              onDone: () {
                if (!hasEvent) controller.add(defaultValue);
                controller.close();
              });
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream;
  }
}

///
extension DefaultIfEmptyExtension<T> on Stream<T> {
  /// Emit items from the source Stream, or a single default item if the source
  /// Stream emits nothing.
  ///
  /// ### Example
  ///
  ///     Stream.empty().defaultIfEmpty(10).listen(print); // prints 10
  Stream<T> defaultIfEmpty(T defaultValue) =>
      transform(DefaultIfEmptyStreamTransformer<T>(defaultValue));
}
