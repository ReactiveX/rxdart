import 'dart:async';

class _FlatMapStreamSink<S, T> implements EventSink<S> {
  final Stream<T> Function(S value) _mapper;
  final EventSink<T> _outputSink;
  int _openSubscriptions = 0;
  bool _inputClosed = false;

  _FlatMapStreamSink(this._outputSink, this._mapper);

  @override
  void add(S data) {
    final mappedStream = _mapper(data);

    _openSubscriptions++;

    mappedStream.listen(_outputSink.add, onError: addError, onDone: () {
      _openSubscriptions--;

      if (_inputClosed && _openSubscriptions == 0) {
        _outputSink.close();
      }
    });
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _inputClosed = true;

    if (_openSubscriptions == 0) {
      _outputSink.close();
    }
  }
}

/// Converts each emitted item into a new Stream using the given mapper
/// function. The newly created Stream will be listened to and begin
/// emitting items downstream.
///
/// The items emitted by each of the new Streams are emitted downstream in the
/// same order they arrive. In other words, the sequences are merged
/// together.
///
/// ### Example
///
///       Stream.fromIterable([4, 3, 2, 1])
///         .transform(FlatMapStreamTransformer((i) =>
///           Stream.fromFuture(
///             Future.delayed(Duration(minutes: i), () => i))
///         .listen(print); // prints 1, 2, 3, 4
class FlatMapStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  /// Method which converts incoming events into a new [Stream]
  final Stream<T> Function(S value) mapper;

  /// Constructs a [StreamTransformer] which emits events from the source [Stream] using the given [mapper].
  /// The mapped [Stream] will be listened to and begin emitting items downstream.
  FlatMapStreamTransformer(this.mapper);

  @override
  Stream<T> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _FlatMapStreamSink<S, T>(sink, mapper));
}

/// Extends the Stream class with the ability to convert the source Stream into
/// a new Stream each time the source emits an item.
extension FlatMapExtension<T> on Stream<T> {
  /// Converts each emitted item into a Stream using the given mapper
  /// function. The newly created Stream will be be listened to and begin
  /// emitting items downstream.
  ///
  /// The items emitted by each of the Streams are emitted downstream in the
  /// same order they arrive. In other words, the sequences are merged
  /// together.
  ///
  /// ### Example
  ///
  ///     RangeStream(4, 1)
  ///       .flatMap((i) => TimerStream(i, Duration(minutes: i))
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<S> flatMap<S>(Stream<S> Function(T value) mapper) =>
      transform(FlatMapStreamTransformer<T, S>(mapper));

  /// Converts each item into a Stream. The Stream must return an
  /// Iterable. Then, each item from the Iterable will be emitted one by one.
  ///
  /// Use case: you may have an API that returns a list of items, such as
  /// a Stream<List<String>>. However, you might want to operate on the individual items
  /// rather than the list itself. This is the job of `flatMapIterable`.
  ///
  /// ### Example
  ///
  ///     RangeStream(1, 4)
  ///       .flatMapIterable((i) => Stream.fromIterable([[i]])
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<S> flatMapIterable<S>(Stream<Iterable<S>> Function(T value) mapper) =>
      transform(FlatMapStreamTransformer<T, Iterable<S>>(mapper))
          .expand((Iterable<S> iterable) => iterable);
}
