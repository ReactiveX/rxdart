import 'dart:async';

/// Maps each emitted item to a new [Stream] using the given predicate, then
/// subscribes to each new stream one after the next until all values are
/// emitted.
///
/// ConcatMap is similar to flatMap, but ensures order by guaranteeing that
/// all items from the created stream will be emitted before moving to the
/// next created stream. This process continues until all created streams have
/// completed.
StreamTransformer<T, S> concatMapTransformer<T, S>(
    Stream<S> predicate(T value)) {
  return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
    final List<Stream<S>> streams = <Stream<S>>[];
    final List<bool> completionStatuses = <bool>[];
    StreamSubscription<S> currentSubscription;
    StreamController<S> controller;
    StreamSubscription<T> subscription;
    bool isParentSubscriptionDone = false;
    int index = 0;

    void moveNext() {
      final int currentIndex = index;

      if (currentSubscription == null && streams[currentIndex] != null) {
        currentSubscription = streams[currentIndex].listen(
            (S value) {
              controller.add(value);
            },
            onError: controller.addError,
            onDone: () {
              completionStatuses[currentIndex] = true;
              currentSubscription.cancel();
              currentSubscription = null;

              if (completionStatuses.every((bool isComplete) => isComplete) &&
                  isParentSubscriptionDone) {
                controller.close();
              } else {
                moveNext();
              }
            });

        index += 1;
      }
    }

    controller = new StreamController<S>(
        sync: true,
        onListen: () {
          subscription = input.listen(
              (T value) {
                streams.add(predicate(value));
                completionStatuses.add(false);

                moveNext();
              },
              onError: controller.addError,
              onDone: () {
                isParentSubscriptionDone = true;
              },
              cancelOnError: cancelOnError);
        },
        onPause: ([Future<dynamic> resumeSignal]) {
          subscription.pause(resumeSignal);

          currentSubscription?.pause(resumeSignal);
        },
        onResume: () {
          subscription.resume();

          currentSubscription?.resume();
        },
        onCancel: () {
          final List<Future<dynamic>> list = <Future<dynamic>>[
            subscription.cancel()
          ];

          if (currentSubscription != null) {
            list.add(currentSubscription.cancel());
          }

          return Future.wait(list
              .where((Future<dynamic> cancelFuture) => cancelFuture != null));
        });

    return controller.stream.listen(null);
  });
}
