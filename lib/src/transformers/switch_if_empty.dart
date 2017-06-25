import 'dart:async';

/// When the original observable emits no items, this operator subscribes to
/// the given fallback stream and emits items from that observable instead.
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
class SwitchIfEmptyStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  SwitchIfEmptyStreamTransformer(Stream<T> fallbackStream)
      : transformer = _buildTransformer(fallbackStream);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Stream<T> fallbackStream) {
    if (fallbackStream == null) {
      throw new ArgumentError('fallbackStream cannot be null');
    }

    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> defaultSubscription;
      StreamSubscription<T> switchSubscription;
      bool hasEvent = false;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            defaultSubscription = input.listen(
                (T value) {
                  hasEvent = true;
                  controller.add(value);
                },
                onError: controller.addError,
                onDone: () {
                  if (!hasEvent) {
                    switchSubscription = fallbackStream.listen((T value) {
                      controller.add(value);
                    },
                        onError: controller.addError,
                        onDone: controller.close,
                        cancelOnError: cancelOnError);
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
          onCancel: () {
            return Future.wait(<Future<dynamic>>[
              defaultSubscription?.cancel(),
              switchSubscription?.cancel()
            ]);
          });

      return controller.stream.listen(null);
    });
  }
}
