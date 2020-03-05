import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';

/// Creates a [Stream] where all emitted items are ignored, only the
/// error / completed notifications are passed
///
/// ### Example
///
///     MergeStream([
///       Stream.fromIterable([1]),
///       ErrorStream(Exception())
///     ])
///     .listen(print, onError: print); // prints Exception
@Deprecated('Use the drain method from the Stream class instead')
class IgnoreElementsStreamTransformer<T> extends StreamTransformerBase<T, T> {
  /// Constructs a [StreamTransformer] which simply ignores all events from
  /// the source [Stream], except for error or completed events.
  IgnoreElementsStreamTransformer();

  @override
  Stream<T> bind(Stream<T> stream) {
    StreamController<T> controller;
    StreamSubscription<T> subscription;

    controller = createController(stream,
        onListen: () {
          subscription = stream.listen(null,
              onError: controller.addError, onDone: () => controller.close());
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller.stream;
  }
}

/// Extends the Stream class with the ability to skip, or ignore, data events.
extension IgnoreElementsExtension<T> on Stream<T> {
  /// Creates a Stream where all emitted items are ignored, only the error /
  /// completed notifications are passed
  ///
  /// ### Example
  ///
  ///    MergeStream([
  ///      Stream.fromIterable([1]),
  ///      Stream.error(Exception())
  ///    ])
  ///    .listen(print, onError: print); // prints Exception
  @Deprecated('Use the drain method from the Stream class instead')
  Stream<T> ignoreElements() => transform(IgnoreElementsStreamTransformer<T>());
}
