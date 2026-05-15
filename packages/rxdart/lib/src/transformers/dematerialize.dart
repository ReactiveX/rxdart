import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/notification.dart';

class _DematerializeStreamSink<S> implements EventSink<StreamNotification<S>> {
  final EventSink<S> _outputSink;

  _DematerializeStreamSink(this._outputSink);

  @override
  void add(StreamNotification<S> data) => data.when(
        data: _outputSink.add,
        done: _outputSink.close,
        error: _outputSink.addErrorAndStackTrace,
      );

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() => _outputSink.close();
}

/// Converts the onData, onDone, and onError [StreamNotification] objects from a
/// materialized stream into normal onData, onDone, and onError events.
///
/// When a stream has been materialized, it emits onData, onDone, and onError
/// events as [StreamNotification] objects. Dematerialize simply reverses this by
/// transforming [StreamNotification] objects back to a normal stream of events.
///
/// ### Example
///
///     Stream<StreamNotification<int>>
///         .fromIterable([StreamNotification.data(1), StreamNotification.done()])
///         .transform(DematerializeStreamTransformer())
///         .listen(print); // Prints 1
///
/// ### Error example
///
///     Stream<StreamNotification<int>>
///         .fromIterable([StreamNotification.error(Exception(), null)])
///         .transform(DematerializeStreamTransformer())
///         .listen(null, onError: (e, s) => print(e)); // Prints Exception
class DematerializeStreamTransformer<S>
    extends StreamTransformerBase<StreamNotification<S>, S> {
  /// Constructs a [StreamTransformer] which converts the onData, onDone, and
  /// onError [StreamNotification] objects from a materialized stream into normal
  /// onData, onDone, and onError events.
  DematerializeStreamTransformer();

  @override
  Stream<S> bind(Stream<StreamNotification<S>> stream) =>
      Stream.eventTransformed(stream, (sink) => _DematerializeStreamSink(sink));
}

/// Converts the onData, onDone, and onError [StreamNotification]s from a
/// materialized stream into normal onData, onDone, and onError events.
extension DematerializeExtension<T> on Stream<StreamNotification<T>> {
  /// Converts the onData, onDone, and onError [StreamNotification] objects from a
  /// materialized stream into normal onData, onDone, and onError events.
  ///
  /// When a stream has been materialized, it emits onData, onDone, and onError
  /// events as [StreamNotification] objects. Dematerialize simply reverses this by
  /// transforming [StreamNotification] objects back to a normal stream of events.
  ///
  /// ### Example
  ///
  ///     Stream<StreamNotification<int>>
  ///         .fromIterable([StreamNotification.data(1), StreamNotification.done()])
  ///         .dematerialize()
  ///         .listen(print); // Prints 1
  ///
  /// ### Error example
  ///
  ///     Stream<StreamNotification<int>>
  ///         .fromIterable([StreamNotification.error(Exception(), null)])
  ///         .dematerialize()
  ///         .listen(null, onError: (e, s) => print(e)); // Prints Exception
  Stream<T> dematerialize() => DematerializeStreamTransformer<T>().bind(this);
}
