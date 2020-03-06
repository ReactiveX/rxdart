import 'dart:async';

class _SwitchMapStreamSink<S, T> implements EventSink<S> {
  final Stream<T> Function(S value) _mapper;
  final EventSink<T> _outputSink;
  StreamSubscription<T> _mapperSubscription;
  bool _inputClosed = false;

  _SwitchMapStreamSink(this._outputSink, this._mapper);

  @override
  void add(S data) {
    final mappedStream = _mapper(data);

    _mapperSubscription?.cancel();

    _mapperSubscription =
        mappedStream.listen(_outputSink.add, onError: addError, onDone: () {
      if (_inputClosed) {
        _outputSink.close();

        _mapperSubscription = null;
      }
    });
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _inputClosed = true;

    _mapperSubscription ?? _outputSink.close();
  }
}

/// Converts each emitted item into a new Stream using the given mapper
/// function. The newly created Stream will be be listened to and begin
/// emitting items, and any previously created Stream will stop emitting.
///
/// The switchMap operator is similar to the flatMap and concatMap
/// methods, but it only emits items from the most recently created Stream.
///
/// This can be useful when you only want the very latest state from
/// asynchronous APIs, for example.
///
/// ### Example
///
///     Stream.fromIterable([4, 3, 2, 1])
///       .transform(SwitchMapStreamTransformer((i) =>
///         Stream.fromFuture(
///           Future.delayed(Duration(minutes: i), () => i))
///       .listen(print); // prints 1
class SwitchMapStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  /// Method which converts incoming events into a new [Stream]
  final Stream<T> Function(S value) mapper;

  /// Constructs a [StreamTransformer] which maps each event from the source [Stream]
  /// using [mapper].
  ///
  /// The mapped [Stream] will be be listened to and begin
  /// emitting items, and any previously created mapper [Stream]s will stop emitting.
  SwitchMapStreamTransformer(this.mapper);

  @override
  Stream<T> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _SwitchMapStreamSink<S, T>(sink, mapper));
}

/// Extends the Stream with the ability to convert one stream into a new Stream
/// whenever the source emits an item. Every time a new Stream is created, the
/// previous Stream is discarded.
extension SwitchMapExtension<T> on Stream<T> {
  /// Converts each emitted item into a Stream using the given mapper function.
  /// The newly created Stream will be be listened to and begin emitting items,
  /// and any previously created Stream will stop emitting.
  ///
  /// The switchMap operator is similar to the flatMap and concatMap methods,
  /// but it only emits items from the most recently created Stream.
  ///
  /// This can be useful when you only want the very latest state from
  /// asynchronous APIs, for example.
  ///
  /// ### Example
  ///
  ///     RangeStream(4, 1)
  ///       .switchMap((i) =>
  ///         TimerStream(i, Duration(minutes: i))
  ///       .listen(print); // prints 1
  Stream<S> switchMap<S>(Stream<S> Function(T value) mapper) =>
      transform(SwitchMapStreamTransformer<T, S>(mapper));
}
