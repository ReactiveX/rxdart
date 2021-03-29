import 'dart:async';
import 'dart:collection';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _DelayStreamSink<S> implements ForwardingSink<S, S> {
  final Duration _duration;
  var _inputClosed = false;
  final _timers = Queue<Timer>();

  _DelayStreamSink(this._duration);

  @override
  void add(EventSink<S> sink, S data) {
    final timer = Timer(_duration, () {
      _timers.removeFirst();

      sink.add(data);

      if (_inputClosed && _timers.isEmpty) {
        sink.close();
      }
    });

    _timers.addLast(timer);
  }

  @override
  void addError(EventSink<S> sink, Object error, StackTrace st) =>
      sink.addError(error, st);

  @override
  void close(EventSink<S> sink) {
    _inputClosed = true;

    if (_timers.isEmpty) {
      sink.close();
    }
  }

  @override
  FutureOr onCancel(EventSink<S> sink) {
    if (_timers.isNotEmpty) {
      _timers.forEach((t) => t.cancel());
      _timers.clear();
    }
  }

  @override
  void onListen(EventSink<S> sink) {}

  @override
  void onPause(EventSink<S> sink) {}

  @override
  void onResume(EventSink<S> sink) {}
}

/// The Delay operator modifies its source Stream by pausing for
/// a particular increment of time (that you specify) before emitting
/// each of the source Stream’s items.
/// This has the effect of shifting the entire sequence of items emitted
/// by the Stream forward in time by that specified increment.
///
/// [Interactive marble diagram](http://rxmarbles.com/#delay)
///
/// ### Example
///
///     Stream.fromIterable([1, 2, 3, 4])
///       .delay(Duration(seconds: 1))
///       .listen(print); // [after one second delay] prints 1, 2, 3, 4 immediately
class DelayStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The delay used to pause initial emission of events by
  final Duration duration;

  /// Constructs a [StreamTransformer] which will first pause for [duration] of time,
  /// before submitting events from the source [Stream].
  DelayStreamTransformer(this.duration);

  @override
  Stream<S> bind(Stream<S> stream) =>
      forwardStream(stream, _DelayStreamSink<S>(duration));
}

/// Extends the Stream class with the ability to delay events being emitted
extension DelayExtension<T> on Stream<T> {
  /// The Delay operator modifies its source Stream by pausing for a particular
  /// increment of time (that you specify) before emitting each of the source
  /// Stream’s items. This has the effect of shifting the entire sequence of
  /// items emitted by the Stream forward in time by that specified increment.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#delay)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4])
  ///       .delay(Duration(seconds: 1))
  ///       .listen(print); // [after one second delay] prints 1, 2, 3, 4 immediately
  Stream<T> delay(Duration duration) =>
      transform(DelayStreamTransformer<T>(duration));
}
