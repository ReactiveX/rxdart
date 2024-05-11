import 'dart:async';

import 'package:rxdart/src/utils/notification.dart';

class _MaterializeStreamSink<S> implements EventSink<S> {
  final EventSink<StreamNotification<S>> _outputSink;

  _MaterializeStreamSink(this._outputSink);

  @override
  void add(S data) => _outputSink.add(StreamNotification.data(data));

  @override
  void addError(e, [st]) => _outputSink.add(StreamNotification.error(e, st));

  @override
  void close() {
    _outputSink.add(StreamNotification.done());
    _outputSink.close();
  }
}

/// Converts the onData, on Done, and onError events into [StreamNotification]
/// objects that are passed into the downstream onData listener.
///
/// The [StreamNotification] object contains the [NotificationKind] of event (OnData, onDone, or
/// OnError), and the item or error that was emitted. In the case of onDone,
/// no data is emitted as part of the [StreamNotification].
///
/// ### Example
///
///     Stream<int>.fromIterable([1])
///         .transform(MaterializeStreamTransformer())
///         .listen(print); // Prints DataNotification{value: 1}, DoneNotification{}
class MaterializeStreamTransformer<S>
    extends StreamTransformerBase<S, StreamNotification<S>> {
  /// Constructs a [StreamTransformer] which transforms the onData, on Done,
  /// and onError events into [StreamNotification] objects.
  MaterializeStreamTransformer();

  @override
  Stream<StreamNotification<S>> bind(Stream<S> stream) =>
      Stream.eventTransformed(
          stream, (sink) => _MaterializeStreamSink<S>(sink));
}

/// Extends the Stream class with the ability to convert the onData, on Done,
/// and onError events into [StreamNotification]s that are passed into the
/// downstream onData listener.
extension MaterializeExtension<T> on Stream<T> {
  /// Converts the onData, on Done, and onError events into [StreamNotification]
  /// objects that are passed into the downstream onData listener.
  ///
  /// The [StreamNotification] object contains the [NotificationKind] of event (OnData, onDone, or
  /// OnError), and the item or error that was emitted. In the case of onDone,
  /// no data is emitted as part of the [StreamNotification].
  ///
  /// Example:
  ///     Stream<int>.fromIterable([1])
  ///         .materialize()
  ///         .listen(print); // Prints DataNotification{value: 1}, DoneNotification{}
  ///
  ///     Stream<int>.error(Exception())
  ///         .materialize()
  ///         .listen(print); // Prints ErrorNotification{error: Exception, stackTrace: }, DoneNotification{}
  Stream<StreamNotification<T>> materialize() =>
      MaterializeStreamTransformer<T>().bind(this);
}
