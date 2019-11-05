import 'dart:async';

import 'package:rxdart/src/streams/zip.dart';

import 'package:rxdart/src/transformers/materialize.dart';

import 'package:rxdart/src/utils/notification.dart';

/// Determine whether two Observables emit the same sequence of items.
/// You can provide an optional equals handler to determine equality.
///
/// [Interactive marble diagram](https://rxmarbles.com/#sequenceEqual)
///
/// ### Example
///
///     new SequenceEqualsStream([
///       Stream.fromIterable([1, 2, 3, 4, 5]),
///       Stream.fromIterable([1, 2, 3, 4, 5])
///     ])
///     .listen(print); // prints true
class SequenceEqualStream<S, T> extends Stream<bool> {
  final StreamController<bool> _controller;

  /// Creates a [Stream] that emits true or false, depending on the
  /// equality between the provided [Stream]s.
  /// This single value is emitted when both provided [Stream]s are complete.
  /// After this event, the [Stream] closes.
  SequenceEqualStream(Stream<S> stream, Stream<T> other,
      {bool equals(S s, T t)})
      : _controller = _buildController(stream, other, equals);

  @override
  StreamSubscription<bool> listen(void onData(bool event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  static StreamController<bool> _buildController<S, T>(
      Stream<S> stream, Stream<T> other, bool equals(S s, T t)) {
    if (stream == null) {
      throw ArgumentError.notNull('stream');
    }

    if (other == null) {
      throw ArgumentError.notNull('other');
    }

    final doCompare = equals ?? (S s, T t) => s == t;
    StreamController<bool> controller;
    StreamSubscription<bool> subscription;

    controller = StreamController<bool>(
        sync: true,
        onListen: () {
          final emitAndClose = ([bool value = true]) => controller
            ..add(value)
            ..close();

          subscription = ZipStream.zip2(
                  stream.transform(MaterializeStreamTransformer()),
                  other.transform(MaterializeStreamTransformer()),
                  (Notification<S> s, Notification<T> t) =>
                      s.kind == t.kind &&
                      s.error?.toString() == t.error?.toString() &&
                      doCompare(s.value, t.value))
              .where((isEqual) => !isEqual)
              .listen(emitAndClose,
                  onError: controller.addError, onDone: emitAndClose);
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel());

    return controller;
  }
}
