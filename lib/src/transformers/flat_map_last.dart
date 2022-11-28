import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _FlatMapLastStreamSink<S, T> extends ForwardingSink<S, T> {
  final Stream<T> Function(S value) _mapper;
  StreamSubscription<T>? _lastSubscription;
  bool _inputClosed = false;

  _FlatMapLastStreamSink(this._mapper);

  @override
  void onData(S data) {
    _lastSubscription?.cancel();

    final Stream<T> mappedStream;
    try {
      mappedStream = _mapper(data);
    } catch (e, s) {
      sink.addError(e, s);
      return;
    }

    final subscription = mappedStream.listen((e) {
      sink.add(e);
    }, onError: sink.addError);
    subscription.onDone(() {
      if (_lastSubscription == subscription) {
        _lastSubscription = null;
        if (_inputClosed) {
          sink.close();
        }
      }
    });
    _lastSubscription = subscription;
  }

  @override
  void onError(Object e, StackTrace st) => sink.addError(e, st);

  @override
  void onDone() {
    if (_lastSubscription == null) {
      sink.close();
    }
    _inputClosed = true;
  }

  @override
  Future<void>? onCancel() {
    return _lastSubscription?.cancel();
  }

  @override
  void onListen() {}

  @override
  void onPause() => _lastSubscription?.pause();

  @override
  void onResume() => _lastSubscription?.resume();
}

/// Converts each emitted item into a new Stream using the given mapper function.
/// The newly created Stream will be listened to and begin emitting items downstream.
/// As soon as a new item is emitted by upstream stream, created stream is closed.
///
/// ### Example
///
/// Stream.fromFutures([
///     Future.delayed(Duration(milliseconds: 1000), () => 'a'),
///     Future.delayed(Duration(milliseconds: 2000), () => 'b')
///   ]).flatMapLast<void>((String value) => Stream.fromFutures([
///       Future.delayed(Duration(milliseconds: 300), () => '$value 1 '),
///       Future.delayed(Duration(milliseconds: 1500), () => '$value 2 '),
///   ])).listen(print);  // prints a1, b1, b2
class FlatMapLastStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  /// Method which converts incoming events into a new [Stream]
  final Stream<T> Function(S value) mapper;

  /// Constructs a [StreamTransformer] which emits events from the source [Stream] using the given [mapper].
  /// The mapped [Stream] will be listened to and begin emitting items downstream.
  FlatMapLastStreamTransformer(this.mapper);

  @override
  Stream<T> bind(Stream<S> stream) =>
      forwardStream(stream, () => _FlatMapLastStreamSink(mapper));
}

/// Converts each emitted item into a new Stream using the given mapper function.
/// The newly created Stream will be listened to and begin emitting items downstream.
/// As soon as a new item is emitted by upstream stream, created stream is closed.
///
/// ### Example
///
/// Stream.fromFutures([
///     Future.delayed(Duration(milliseconds: 1000), () => 'a'),
///     Future.delayed(Duration(milliseconds: 2000), () => 'b')
///   ]).flatMapLast<void>((String value) => Stream.fromFutures([
///       Future.delayed(Duration(milliseconds: 300), () => '$value 1 '),
///       Future.delayed(Duration(milliseconds: 1500), () => '$value 2 '),
///   ])).listen(print);  // prints a1, b1, b2
extension FlatMapLastExtension<T> on Stream<T> {
  /// Converts each emitted item into a new Stream using the given mapper function.
  /// The newly created Stream will be listened to and begin emitting items downstream.
  /// As soon as a new item is emitted by upstream stream, created stream is closed.
  ///
  /// ### Example
  ///
  /// Stream.fromFutures([
  ///     Future.delayed(Duration(milliseconds: 1000), () => 'a'),
  ///     Future.delayed(Duration(milliseconds: 2000), () => 'b')
  ///   ]).flatMapLast<void>((String value) => Stream.fromFutures([
  ///       Future.delayed(Duration(milliseconds: 300), () => '$value 1 '),
  ///       Future.delayed(Duration(milliseconds: 1500), () => '$value 2 '),
  ///   ])).listen(print);  // prints a1, b1, b2
  Stream<S> flatMapLast<S>(Stream<S> Function(T value) mapper) =>
      FlatMapLastStreamTransformer<T, S>(mapper).bind(this);
}
