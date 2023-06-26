import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/notification.dart';

class _DematerializeStreamSink<S> implements EventSink<RxNotification<S>> {
  final EventSink<S> _outputSink;

  _DematerializeStreamSink(this._outputSink);

  @override
  void add(RxNotification<S> data) => data.when(
        data: _outputSink.add,
        done: _outputSink.close,
        error: _outputSink.addErrorAndStackTrace,
      );

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() => _outputSink.close();
}

/// Converts the onData, onDone, and onError [RxNotification] objects from a
/// materialized stream into normal onData, onDone, and onError events.
///
/// When a stream has been materialized, it emits onData, onDone, and onError
/// events as [RxNotification] objects. Dematerialize simply reverses this by
/// transforming [RxNotification] objects back to a normal stream of events.
///
/// ### Example
///
///     Stream<RxNotification<int>>
///         .fromIterable([RxNotification.onData(1), RxNotification.onDone()])
///         .transform(DematerializeStreamTransformer())
///         .listen((i) => print(i)); // Prints 1
///
/// ### Error example
///
///     Stream<RxNotification<int>>
///         .fromIterable([RxNotification.onError(Exception(), null)])
///         .transform(DematerializeStreamTransformer())
///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
class DematerializeStreamTransformer<S>
    extends StreamTransformerBase<RxNotification<S>, S> {
  /// Constructs a [StreamTransformer] which converts the onData, onDone, and
  /// onError [RxNotification] objects from a materialized stream into normal
  /// onData, onDone, and onError events.
  DematerializeStreamTransformer();

  @override
  Stream<S> bind(Stream<RxNotification<S>> stream) =>
      Stream.eventTransformed(stream, (sink) => _DematerializeStreamSink(sink));
}

/// Converts the onData, onDone, and onError [RxNotification]s from a
/// materialized stream into normal onData, onDone, and onError events.
extension DematerializeExtension<T> on Stream<RxNotification<T>> {
  /// Converts the onData, onDone, and onError [RxNotification] objects from a
  /// materialized stream into normal onData, onDone, and onError events.
  ///
  /// When a stream has been materialized, it emits onData, onDone, and onError
  /// events as [RxNotification] objects. Dematerialize simply reverses this by
  /// transforming [RxNotification] objects back to a normal stream of events.
  ///
  /// ### Example
  ///
  ///     Stream<RxNotification<int>>
  ///         .fromIterable([RxNotification.onData(1), RxNotification.onDone()])
  ///         .dematerialize()
  ///         .listen((i) => print(i)); // Prints 1
  ///
  /// ### Error example
  ///
  ///     Stream<RxNotification<int>>
  ///         .fromIterable([RxNotification.onError(Exception(), null)])
  ///         .dematerialize()
  ///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
  Stream<T> dematerialize() => DematerializeStreamTransformer<T>().bind(this);
}
