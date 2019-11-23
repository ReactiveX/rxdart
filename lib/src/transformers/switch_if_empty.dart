import 'dart:async';

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
class SwitchIfEmptyStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which, when the source [Stream] emits
  /// no events, switches over to [fallbackStream].
  SwitchIfEmptyStreamTransformer(Stream<T> fallbackStream)
      : _transformer = _buildTransformer(fallbackStream);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Stream<T> fallbackStream) {
    if (fallbackStream == null) {
      throw ArgumentError('fallbackStream cannot be null');
    }

    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> defaultSubscription;
      StreamSubscription<T> switchSubscription;
      var hasEvent = false;

      void onDone() {
        if (controller.isClosed) return;

        controller.close();
        switchSubscription?.cancel();
      }

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            defaultSubscription = input.listen(
                (T value) {
                  hasEvent = true;
                  controller.add(value);
                },
                onError: controller.addError,
                onDone: () {
                  if (hasEvent) {
                    controller.close();
                  } else {
                    switchSubscription = fallbackStream.listen(
                      controller.add,
                      onError: controller.addError,
                      onDone: onDone,
                      cancelOnError: cancelOnError,
                    );
                  }
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            defaultSubscription?.pause(resumeSignal);
            switchSubscription?.pause(resumeSignal);
          },
          onResume: () {
            defaultSubscription?.resume();
            switchSubscription?.resume();
          },
          onCancel: () => defaultSubscription?.cancel());

      return controller.stream.listen(null);
    });
  }
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
