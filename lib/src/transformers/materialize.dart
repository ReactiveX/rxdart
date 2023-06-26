import 'dart:async';

import 'package:rxdart/src/utils/notification.dart';

class _MaterializeStreamSink<S> implements EventSink<S> {
  final EventSink<RxNotification<S>> _outputSink;

  _MaterializeStreamSink(this._outputSink);

  @override
  void add(S data) => _outputSink.add(RxNotification.data(data));

  @override
  void addError(e, [st]) => _outputSink.add(RxNotification.error(e, st));

  @override
  void close() {
    _outputSink.add(RxNotification.done());
    _outputSink.close();
  }
}

/// Converts the onData, on Done, and onError events into [RxNotification]
/// objects that are passed into the downstream onData listener.
///
/// The [RxNotification] object contains the [NotificationKind] of event (OnData, onDone, or
/// OnError), and the item or error that was emitted. In the case of onDone,
/// no data is emitted as part of the [RxNotification].
///
/// ### Example
///
///     Stream<int>.fromIterable([1])
///         .transform(MaterializeStreamTransformer())
///         .listen((i) => print(i)); // Prints onData & onDone RxNotification
class MaterializeStreamTransformer<S>
    extends StreamTransformerBase<S, RxNotification<S>> {
  /// Constructs a [StreamTransformer] which transforms the onData, on Done,
  /// and onError events into [RxNotification] objects.
  MaterializeStreamTransformer();

  @override
  Stream<RxNotification<S>> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _MaterializeStreamSink<S>(sink));
}

/// Extends the Stream class with the ability to convert the onData, on Done,
/// and onError events into [RxNotification]s that are passed into the
/// downstream onData listener.
extension MaterializeExtension<T> on Stream<T> {
  /// Converts the onData, on Done, and onError events into [RxNotification]
  /// objects that are passed into the downstream onData listener.
  ///
  /// The [RxNotification] object contains the [NotificationKind] of event (OnData, onDone, or
  /// OnError), and the item or error that was emitted. In the case of onDone,
  /// no data is emitted as part of the [RxNotification].
  ///
  /// Example:
  ///     Stream<int>.fromIterable([1])
  ///         .materialize()
  ///         .listen((i) => print(i)); // Prints onData & onDone RxNotification
  ///
  ///     Stream<int>.error(Exception())
  ///         .materialize()
  ///         .listen((i) => print(i)); // Prints onError RxNotification
  Stream<RxNotification<T>> materialize() =>
      MaterializeStreamTransformer<T>().bind(this);
}
