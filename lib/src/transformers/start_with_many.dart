import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Prepends a sequence of values to the source Stream.
///
/// ### Example
///
///     Stream.fromIterable([3])
///       .transform(StartWithManyStreamTransformer([1, 2]))
///       .listen(print); // prints 1, 2, 3
class StartWithManyStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// The starting events of this [Stream]
  final Iterable<T> startValues;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with all values from [startValues].
  StartWithManyStreamTransformer(this.startValues);

  @override
  Stream<T> bind(Stream<T> stream) {
    if (startValues == null) {
      throw ArgumentError('startValues cannot be null');
    }

    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = createController(stream,
        onListen: () {
          final prependedStream = () async* {
            for (var i = 0, len = startValues.length; i < len; i++) {
              yield startValues.elementAt(i);
            }

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

/// Extends the Stream class with the ability to emit the given values as the
/// first items.
extension StartWithManyExtension<T> on Stream<T> {
  /// Prepends a sequence of values to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([3]).startWithMany([1, 2])
  ///       .listen(print); // prints 1, 2, 3
  Stream<T> startWithMany(List<T> startValues) =>
      transform(StartWithManyStreamTransformer<T>(startValues));
}
