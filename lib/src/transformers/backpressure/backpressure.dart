import 'dart:async';

import 'dart:collection';

enum WindowStrategy { everyEvent, eventAfterLastWindow, firstEventOnly, never }

class BackpressureStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> transformer;

  BackpressureStreamTransformer(
      WindowStrategy strategy, Stream<dynamic> windowStreamFactory(S event),
      {T onWindowStart(S event),
      T onWindowEnd(List<S> queue),
      int startBufferEvery = 0,
      bool closeWindowWhen(List<S> queue),
      bool ignoreEmptyWindows = true,
      bool dispatchOnClose = true})
      : transformer = _buildTransformer(
            strategy,
            windowStreamFactory,
            onWindowStart,
            onWindowEnd,
            startBufferEvery,
            closeWindowWhen,
            ignoreEmptyWindows,
            dispatchOnClose);

  @override
  Stream<T> bind(Stream<S> stream) => transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>(
      WindowStrategy strategy,
      Stream<dynamic> windowStreamFactory(S event),
      T onWindowStart(S event),
      T onWindowEnd(List<S> queue),
      int startBufferEvery,
      bool closeWindowWhen(List<S> queue),
      bool ignoreEmptyWindows,
      bool dispatchOnClose) {
    return StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<S> subscription;
      StreamSubscription windowSubscription;
      var skip = 0;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            // the Queue which is built while a Window frame is open
            final queue = Queue<S>();
            // handles the start of a Window frame
            final resolveWindowStart = (S event) {
              if (onWindowStart != null) controller.add(onWindowStart(event));
            };
            // handles the end of a Window frame
            final resolveWindowEnd = ([bool isControllerClosing = false]) {
              if (isControllerClosing ||
                  strategy == WindowStrategy.eventAfterLastWindow ||
                  strategy == WindowStrategy.everyEvent) {
                windowSubscription?.cancel();
                windowSubscription = null;
              }

              if (isControllerClosing && !dispatchOnClose) return;

              if (queue.isNotEmpty || !ignoreEmptyWindows) {
                if (onWindowEnd != null) {
                  try {
                    controller.add(onWindowEnd(List<S>.unmodifiable(queue)));
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                }

                if (!isControllerClosing && startBufferEvery > 0) {
                  try {
                    final startWith = (startBufferEvery < queue.length)
                        ? queue.toList().sublist(startBufferEvery)
                        : <S>[];

                    skip = startBufferEvery > queue.length
                        ? startBufferEvery - queue.length
                        : 0;

                    queue
                      ..clear()
                      ..addAll(startWith);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                } else {
                  queue.clear();
                }
              }
            };
            // tries to create a new Stream from the window factory method
            final buildStream = (S event) {
              Stream stream;

              try {
                stream = windowStreamFactory(event);
              } catch (e, s) {
                controller.addError(e, s);
              }

              if (stream == null)
                controller
                    .addError(ArgumentError.notNull('windowStreamFactory'));

              return stream;
            };
            // opens a new Window which fires once, then closes
            final singleWindow = (S event) => buildStream(event).take(1).listen(
                null,
                onError: controller.addError,
                onDone: resolveWindowEnd,
                cancelOnError: cancelOnError);
            // opens a new Window which is kept open until the main Stream
            // closes.
            final multiWindow = (S event) => buildStream(event).listen(
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

                    resolveWindowStart(event);

                    break;
                  // for example scan
                  case WindowStrategy.firstEventOnly:
                    if (windowSubscription != null) return;

                    windowSubscription = multiWindow(event);

                    resolveWindowStart(event);

                    break;
                  // for example debounce
                  case WindowStrategy.everyEvent:
                    windowSubscription?.cancel();

                    windowSubscription = singleWindow(event);

                    resolveWindowStart(event);

                    break;
                  case WindowStrategy.never:
                    break;
                }
              } catch (e, s) {
                controller.addError(e, s);
              }
            };
            final maybeCloseWindow = () {
              if (closeWindowWhen != null &&
                  closeWindowWhen(List<S>.unmodifiable(queue))) {
                resolveWindowEnd();
              }
            };

            subscription = input.listen(
                (event) {
                  maybeCreateWindow(event);

                  if (skip == 0) queue.add(event);

                  if (skip > 0) skip--;

                  maybeCloseWindow();
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
