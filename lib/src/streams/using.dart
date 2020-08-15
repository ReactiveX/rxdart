import 'dart:async';

/// When listener listens to it, creates a resource object from resource factory function,
/// and creates a [Stream] from the given factory function and resource as argument.
/// Finally when the stream finishes emitting items or stream subscription
/// is cancelled (call [StreamSubscription.cancel] or `Stream.listen(cancelOnError: true)`),
/// call the disposer function on resource object.
///
/// ### Example
///
///     UsingStream(
///       () => res,
///       (res) => Stream.value(1),
///       (res) => res.close(),
///     ).listen(print); // prints 1
/// TODO: using
class UsingStream<T, R> extends StreamView<T> {
  /// TODO: using
  UsingStream(
    R Function() resourceFactory,
    Stream<T> Function(R) streamFactory,
    FutureOr<void> Function(R) disposer,
  ) : super(_buildStream(resourceFactory, streamFactory, disposer));

  static Stream<T> _buildStream<T, R>(
    R Function() resourceFactory,
    Stream<T> Function(R) streamFactory,
    FutureOr<void> Function(R) disposer,
  ) {
    ArgumentError.checkNotNull(resourceFactory, 'resourceFactory');
    ArgumentError.checkNotNull(streamFactory, 'streamFactory');
    ArgumentError.checkNotNull(disposer, 'disposer');

    StreamController<T> controller;
    var resourceCreated = false;
    R resource;
    StreamSubscription<T> subscription;

    controller = StreamController<T>(
      sync: true,
      onListen: () {
        try {
          resource = resourceFactory();
          resourceCreated = true;
        } catch (e, s) {
          controller.addError(e, s);
          controller.close();
          return;
        }

        Stream<T> stream;
        try {
          stream = streamFactory(resource);
        } catch (e, s) {
          controller.addError(e, s);
          controller.close();
          return;
        }

        subscription = stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () async {
        final futureOr = resourceCreated ? disposer(resource) : null;
        final cancelFuture = subscription?.cancel();

        final futures = [
          // ignore: unnecessary_cast
          if (futureOr is Future<void>) futureOr as Future<void>,
          if (cancelFuture is Future<void>) cancelFuture,
        ];
        if (futures.isNotEmpty) {
          await Future.wait(futures);
        }
      },
    );

    return controller.stream;
  }
}
