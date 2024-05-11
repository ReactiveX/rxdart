import 'dart:async';

/// When listener listens to it, creates a resource object from resource factory function,
/// and creates a [Stream] from the given factory function and resource as argument.
/// Finally when the stream finishes emitting items or stream subscription
/// is cancelled (call [StreamSubscription.cancel] or `Stream.listen(cancelOnError: true)`),
/// call the disposer function on resource object.
/// The disposer is called after the future returned from [StreamSubscription.cancel] completes.
///
/// The [UsingStream] is a way you can instruct a Stream to create
/// a resource that exists only during the lifespan of the Stream
/// and is disposed of when the Stream terminates.
///
/// [Marble diagram](http://reactivex.io/documentation/operators/images/using.c.png)
///
/// ### Example
///
///     UsingStream<int, Queue<int>>(
///       resourceFactory: () => Queue.of([1, 2, 3]),
///       streamFactory: (r) => Stream.fromIterable(r),
///       disposer: (r) => r.clear(),
///     ).listen(print); // prints 1, 2, 3
class UsingStream<T, R> extends StreamView<T> {
  /// Construct a [UsingStream] that creates a resource object from [resourceFactory],
  /// and then creates a [Stream] from [streamFactory] and resource as argument.
  /// When the Stream terminates, call [disposer] on resource object.
  UsingStream({
    required FutureOr<R> Function() resourceFactory,
    required Stream<T> Function(R) streamFactory,
    required FutureOr<void> Function(R) disposer,
  }) : super(_buildStream(resourceFactory, streamFactory, disposer));

  static Stream<T> _buildStream<T, R>(
    FutureOr<R> Function() resourceFactory,
    Stream<T> Function(R) streamFactory,
    FutureOr<void> Function(R) disposer,
  ) {
    late StreamController<T> controller;
    var resourceCreated = false;
    late R resource;
    StreamSubscription<T>? subscription;

    void useResource(R r) {
      resource = r;
      resourceCreated = true;

      Stream<T> stream;
      try {
        stream = streamFactory(r);
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
    }

    controller = StreamController<T>(
      sync: true,
      onListen: () {
        final FutureOr<R> resourceOrFuture;
        try {
          resourceOrFuture = resourceFactory();
        } catch (e, s) {
          controller.addError(e, s);
          controller.close();
          return;
        }

        if (resourceOrFuture is R) {
          useResource(resourceOrFuture);
        } else {
          resourceOrFuture.then((r) {
            // if the controller was cancelled before the resource is created,
            // we should dispose the resource
            if (!controller.hasListener) {
              disposer(r);
            } else {
              useResource(r);
            }
          }).onError<Object>((e, s) {
            controller.addError(e, s);
            controller.close();
          });
        }
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        final cancelFuture = subscription?.cancel();
        subscription = null;

        return cancelFuture == null
            ? (resourceCreated ? disposer(resource) : null)
            : cancelFuture
                .then((_) => resourceCreated ? disposer(resource) : null);
      },
    );

    return controller.stream;
  }
}
