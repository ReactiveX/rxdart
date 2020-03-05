import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Prepends a value to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithStreamTransformer(1))
///       .listen(print); // prints 1, 2
class StartWithStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// The starting event of this [Stream]
  final T startValue;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  StartWithStreamTransformer(this.startValue);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = createController(stream,
        onListen: () {
          final prependedStream = () async* {
            yield startValue;
            yield* stream;
          };

          subscription = prependedStream().listen(controller.add,
              onError: controller.addError, onDone: controller.close);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream;
  }
}

/// Extends the Stream class with the ability to emit the given value as the
/// first item.
extension StartWithExtension<T> on Stream<T> {
  /// Prepends a value to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2]).startWith(1).listen(print); // prints 1, 2
  Stream<T> startWith(T startValue) =>
      transform(StartWithStreamTransformer<T>(startValue));
}
