import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _StartWithStreamSink<S> extends ForwardingSink<S, S> {
  final S _startValue;

  late final queue = Queue<StreamNotification<S>>()
    ..add(StreamNotification.data(_startValue));
  var _isCancelled = false;

  _StartWithStreamSink(this._startValue);

  @override
  void onData(S data) {
    if (queue.isEmpty) {
      sink.add(data);
    } else {
      queue.add(StreamNotification.data(data));
    }
  }

  @override
  void onError(Object e, StackTrace st) {
    if (queue.isEmpty) {
      sink.addError(e, st);
    } else {
      queue.add(StreamNotification.error(e, st));
    }
  }

  @override
  void onDone() {
    if (queue.isEmpty) {
      sink.close();
    } else {
      queue.add(DoneNotification());
    }
  }

  @override
  FutureOr<void> onCancel() {
    _isCancelled = true;
  }

  @override
  void onListen() {
    scheduleMicrotask(() {
      final add = sink.add;
      final addError = sink.addError;
      final close = sink.close;

      while (queue.isNotEmpty) {
        if (_isCancelled) {
          queue.clear();
          return;
        }
        queue.removeFirst().when(data: add, error: addError, done: close);
      }
    });
  }

  @override
  void onPause() {}

  @override
  void onResume() {}
}

/// Prepends a value to the source [Stream].
///
/// ### Example
///
///     Stream.fromIterable([2])
///       .transform(StartWithStreamTransformer(1))
///       .listen(print); // prints 1, 2
class StartWithStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The starting event of this [Stream]
  final S startValue;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  StartWithStreamTransformer(this.startValue);

  @override
  Stream<S> bind(Stream<S> stream) =>
      forwardStream(stream, () => _StartWithStreamSink(startValue));
}

/// Extends the [Stream] class with the ability to emit the given value as the
/// first item.
extension StartWithExtension<T> on Stream<T> {
  /// Prepends a value to the source [Stream].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2]).startWith(1).listen(print); // prints 1, 2
  Stream<T> startWith(T startValue) =>
      StartWithStreamTransformer<T>(startValue).bind(this);
}
