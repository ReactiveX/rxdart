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
            // the Queue which is built while a Window frame is open
            final queue = Queue<S>();
            // handles the start of a Window frame
            final resolveWindowStart = (S event) {
              if (onWindowStart != null) controller.add(onWindowStart(event));
            };
            // determines whether the last open Window should close
            final maybeCloseOpenWindow = (bool forceClose) {
              if (forceClose ||
                  strategy == WindowStrategy.eventAfterLastWindow ||
                  strategy == WindowStrategy.everyEvent) {
                windowSubscription?.cancel();
                windowSubscription = null;
              }
            };
            // handles the end of a Window frame
            final resolveWindowEnd = ([bool isControllerClosing = false]) {
              maybeCloseOpenWindow(isControllerClosing);

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
            // opens a new Window which fires once, then closes
            final singleWindow = (S event) => windowStreamFactory(event)
                .take(1)
                .listen(null,
                    onError: controller.addError,
                    onDone: resolveWindowEnd,
                    cancelOnError: cancelOnError);
            // opens a new Window which is kept open until the main Stream
            // closes.
            final multiWindow = (S event) => windowStreamFactory(event).listen(
                (dynamic _) => resolveWindowEnd(),
                onError: controller.addError,
                onDone: resolveWindowEnd,
                cancelOnError: cancelOnError);
            final maybeCreateWindow = (S event) {
              try {
                switch (strategy) {
                  // for example throttle
                  case WindowStrategy.eventAfterLastWindow:
                    if (windowSubscription != null) return;

                    windowSubscription = singleWindow(event);

                    break;
                  // for example scan
                  case WindowStrategy.firstEventOnly:
                    if (windowSubscription != null) return;

                    windowSubscription = multiWindow(event);

                    break;
                  // for example debounce
                  case WindowStrategy.everyEvent:
                    windowSubscription?.cancel();

                    windowSubscription = singleWindow(event);

                    break;
                }

                resolveWindowStart(event);
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
                  // treat the final event as a Window that opens
                  // and immediately closes again
                  if (queue.isNotEmpty) resolveWindowStart(queue.last);

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
