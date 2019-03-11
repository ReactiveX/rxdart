import 'dart:async';

import 'dart:collection';

enum WindowStrategy {
  restartOnEvent,
  awaitWindowCompletion,
  startAfterFirstEvent
}

class BackpressureStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  BackpressureStreamTransformer(
      WindowStrategy strategy,
      Stream<dynamic> windowStreamFactory(T event),
      T onWindowStart(T event),
      T onWindowEnd(Iterable<T> queue),
      {bool ignoreEmptyWindows = true})
      : transformer = _buildTransformer(strategy, windowStreamFactory,
            onWindowStart, onWindowEnd, ignoreEmptyWindows);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      WindowStrategy strategy,
      Stream<dynamic> windowStreamFactory(T event),
      T onWindowStart(T event),
      T onWindowEnd(Iterable<T> queue),
      bool ignoreEmptyWindows) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      StreamSubscription windowSubscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            final queue = Queue<T>();
            final resolveWindowEnd = () {
              if (strategy == WindowStrategy.awaitWindowCompletion ||
                  strategy == WindowStrategy.restartOnEvent) {
                windowSubscription?.cancel();
                windowSubscription = null;
              }

              if (queue.isNotEmpty || !ignoreEmptyWindows) {
                if (onWindowEnd != null) {
                  try {
                    controller.add(onWindowEnd(List<T>.unmodifiable(queue)));
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                }

                queue.clear();
              }
            };
            final maybeCreateWindow = (T event) {
              try {
                switch (strategy) {
                  case WindowStrategy.awaitWindowCompletion:
                    if (windowSubscription != null) return;

                    windowSubscription = windowStreamFactory(event)
                        .take(1)
                        .listen(null,
                            onError: controller.addError,
                            onDone: resolveWindowEnd,
                            cancelOnError: cancelOnError);

                    break;
                  case WindowStrategy.startAfterFirstEvent:
                    if (windowSubscription != null) return;

                    windowSubscription = windowStreamFactory(event).listen(
                        (dynamic _) => resolveWindowEnd(),
                        onError: controller.addError,
                        onDone: resolveWindowEnd,
                        cancelOnError: cancelOnError);

                    break;
                  case WindowStrategy.restartOnEvent:
                    windowSubscription?.cancel();

                    windowSubscription = windowStreamFactory(event)
                        .take(1)
                        .listen(null,
                            onError: controller.addError,
                            onDone: resolveWindowEnd,
                            cancelOnError: cancelOnError);

                    break;
                }

                if (onWindowStart != null) controller.add(onWindowStart(event));
              } catch (e, s) {
                controller.addError(e, s);
              }
            };

            subscription = input.listen(
                (event) {
                  maybeCreateWindow(event);
                  queue.add(event);
                },
                onError: controller.addError,
                onDone: () {
                  onWindowEnd = (Iterable<T> queue) =>
                      queue.isNotEmpty ? queue.last : null;
                  resolveWindowEnd();
                  controller.close();
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
