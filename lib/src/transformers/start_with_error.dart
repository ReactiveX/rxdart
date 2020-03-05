import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Prepends an error to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithErrorStreamTransformer('error'))
///       .listen(null, onError: (e) => print(e)); // prints 'error'
class StartWithErrorStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// The starting error of this [Stream]
  final Object error;

  /// The starting stackTrace of this [Stream]
  final StackTrace stackTrace;

  /// Constructs a [StreamTransformer] which starts with the provided [error]
  /// and then outputs all events from the source [Stream].
  StartWithErrorStreamTransformer(this.error, [this.stackTrace]);

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = createController(stream,
        onListen: () {
          final prependedStream = () async* {
            controller.addError(error, stackTrace);

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
