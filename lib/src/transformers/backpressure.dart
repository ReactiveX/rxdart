import 'dart:async';

import 'dart:collection';

enum WindowStrategy { everyEvent, eventAfterLastWindow, firstEventOnly }

class BackpressureStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> transformer;

  BackpressureStreamTransformer(
      WindowStrategy strategy,
      Stream<dynamic> windowStreamFactory(S event),
      T onWindowStart(S event),
      T onWindowEnd(Iterable<S> queue),
      {bool ignoreEmptyWindows = true})
      : transformer = _buildTransformer(strategy, windowStreamFactory,
            onWindowStart, onWindowEnd, ignoreEmptyWindows);

  @override
  Stream<T> bind(Stream<S> stream) => transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>(
      WindowStrategy strategy,
      Stream<dynamic> windowStreamFactory(S event),
      T onWindowStart(S event),
      T onWindowEnd(Iterable<S> queue),
      bool ignoreEmptyWindows) {
    return StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<S> subscription;
      StreamSubscription windowSubscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            final queue = Queue<S>();
            final resolveWindowEnd = ([bool forceClose = false]) {
              if (forceClose ||
                  strategy == WindowStrategy.eventAfterLastWindow ||
                  strategy == WindowStrategy.everyEvent) {
                windowSubscription?.cancel();
                windowSubscription = null;
              }

              if (queue.isNotEmpty || !ignoreEmptyWindows) {
                if (onWindowEnd != null) {
                  try {
                    controller.add(onWindowEnd(List<S>.unmodifiable(queue)));
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                }

                queue.clear();
              }
            };
            final maybeCreateWindow = (S event) {
              try {
                switch (strategy) {
                  case WindowStrategy.eventAfterLastWindow:
                    if (windowSubscription != null) return;

                    windowSubscription = windowStreamFactory(event)
                        .take(1)
                        .listen(null,
                            onError: controller.addError,
                            onDone: resolveWindowEnd,
                            cancelOnError: cancelOnError);

                    break;
                  case WindowStrategy.firstEventOnly:
                    if (windowSubscription != null) return;

                    windowSubscription = windowStreamFactory(event).listen(
                        (dynamic _) => resolveWindowEnd(),
                        onError: controller.addError,
                        onDone: resolveWindowEnd,
                        cancelOnError: cancelOnError);

                    break;
                  case WindowStrategy.everyEvent:
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
                  if (onWindowStart != null && queue.isNotEmpty)
                    controller.add(onWindowStart(queue.last));

                  resolveWindowEnd(true);

                  queue.clear();
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
