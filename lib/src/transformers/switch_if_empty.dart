import 'dart:async';

class _SwitchIfEmptyStreamSink<S> implements EventSink<S> {
  final Stream<S> _fallbackStream;
  final EventSink<S> _outputSink;
  var _isEmpty = true;

  _SwitchIfEmptyStreamSink(this._outputSink, this._fallbackStream);

  @override
  void add(S data) {
    _isEmpty = false;
    _outputSink.add(data);
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    if (_isEmpty) {
      _fallbackStream.listen(_outputSink.add, onError: _outputSink.addError,
          onDone: () {
        _outputSink.close();
      });
    } else {
      _outputSink.close();
    }
  }
}

/// When the original stream emits no items, this operator subscribes to
/// the given fallback stream and emits items from that stream instead.
///
/// This can be particularly useful when consuming data from multiple sources.
/// For example, when using the Repository Pattern. Assuming you have some
/// data you need to load, you might want to start with the fastest access
/// point and keep falling back to the slowest point. For example, first query
/// an in-memory database, then a database on the file system, then a network
/// call if the data isn't on the local machine.
///
/// This can be achieved quite simply with switchIfEmpty!
///
/// ### Example
///
///     // Let's pretend we have some Data sources that complete without emitting
///     // any items if they don't contain the data we're looking for
///     Stream<Data> memory;
///     Stream<Data> disk;
///     Stream<Data> network;
///
///     // Start with memory, fallback to disk, then fallback to network.
///     // Simple as that!
///     Stream<Data> getThatData =
///         memory.switchIfEmpty(disk).switchIfEmpty(network);
class SwitchIfEmptyStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// The [Stream] which will be used as fallback, if the source [Stream] is empty.
  final Stream<S> fallbackStream;

  /// Constructs a [StreamTransformer] which, when the source [Stream] emits
  /// no events, switches over to [fallbackStream].
  SwitchIfEmptyStreamTransformer(this.fallbackStream) {
    if (fallbackStream == null) {
      throw ArgumentError('fallbackStream cannot be null');
    }
  }

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _SwitchIfEmptyStreamSink<S>(sink, fallbackStream));
}

/// Extend the Stream class with the ability to return an alternative Stream
/// if the initial Stream completes with no items.
extension SwitchIfEmptyExtension<T> on Stream<T> {
  /// When the original Stream emits no items, this operator subscribes to the
  /// given fallback stream and emits items from that Stream instead.
  ///
  /// This can be particularly useful when consuming data from multiple sources.
  /// For example, when using the Repository Pattern. Assuming you have some
  /// data you need to load, you might want to start with the fastest access
  /// point and keep falling back to the slowest point. For example, first query
  /// an in-memory database, then a database on the file system, then a network
  /// call if the data isn't on the local machine.
  ///
  /// This can be achieved quite simply with switchIfEmpty!
  ///
  /// ### Example
  ///
  ///     // Let's pretend we have some Data sources that complete without
  ///     // emitting any items if they don't contain the data we're looking for
  ///     Stream<Data> memory;
  ///     Stream<Data> disk;
  ///     Stream<Data> network;
  ///
  ///     // Start with memory, fallback to disk, then fallback to network.
  ///     // Simple as that!
  ///     Stream<Data> getThatData =
  ///         memory.switchIfEmpty(disk).switchIfEmpty(network);
  Stream<T> switchIfEmpty(Stream<T> fallbackStream) =>
      transform(SwitchIfEmptyStreamTransformer<T>(fallbackStream));
}
