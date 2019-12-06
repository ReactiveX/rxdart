import 'dart:async';
import 'dart:collection';

/// The strategy that is used to determine how and when a new window is created.
enum WindowStrategy {
  /// cancels the open window (if any) and immediately opens a fresh one.
  everyEvent,

  /// waits until the current open window completes, then when the
  /// source [Stream] emits a next event, it opens a new window.
  eventAfterLastWindow,

  /// opens a recurring window right after the very first event on
  /// the source [Stream] is emitted.
  firstEventOnly,

  /// does not open any windows, rather all events are buffered and emitted
  /// whenever the handler triggers, after this trigger, the buffer is cleared.
  onHandler
}

/// A highly customizable [StreamTransformer] which can be configured
/// to serve any of the common rx backpressure operators.
///
/// The [StreamTransformer] works by creating windows, during which it
/// buffers events to a [Queue].
///
/// The [StreamTransformer] works by creating windows, during which it
/// buffers events to a [Queue]. It uses a  [WindowStrategy] to determine
/// how and when a new window is created.
///
/// onWindowStart and onWindowEnd are handlers that fire when a window
/// opens and closes, right before emitting the transformed event.
///
/// startBufferEvery allows to skip events coming from the source [Stream].
///
/// ignoreEmptyWindows can be set to true, to allow events to be emitted
/// at the end of a window, even if the current buffer is empty.
/// If the buffer is empty, then an empty [List] will be emitted.
/// If false, then nothing is emitted on an empty buffer.
///
/// dispatchOnClose will cause the remaining values in the buffer to be
/// emitted when the source [Stream] closes.
/// When false, the remaining buffer is discarded on close.
class BackpressureStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> _transformer;

  /// Constructs a [StreamTransformer] which buffers events emitted by the
  /// [Stream] that is created by [windowStreamFactory].
  ///
  /// Use the various optional parameters to precisely determine how and when
  /// this buffer should be created.
  ///
  /// For more info on the parameters, see [BackpressureStreamTransformer],
  /// or see the various back pressure [StreamTransformer]s for examples.
  BackpressureStreamTransformer(WindowStrategy strategy,
      Stream<dynamic> Function(S event) windowStreamFactory,
      {T Function(S event) onWindowStart,
      T Function(List<S> queue) onWindowEnd,
      int startBufferEvery = 0,
      bool Function(List<S> queue) closeWindowWhen,
      bool ignoreEmptyWindows = true,
      bool dispatchOnClose = true})
      : _transformer = _buildTransformer(
            strategy,
            windowStreamFactory,
            onWindowStart,
            onWindowEnd,
            startBufferEvery,
            closeWindowWhen,
            ignoreEmptyWindows,
            dispatchOnClose);

  @override
  Stream<T> bind(Stream<S> stream) => _transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>(
      WindowStrategy strategy,
      Stream<dynamic> Function(S event) windowStreamFactory,
      T Function(S event) onWindowStart,
      T Function(List<S> queue) onWindowEnd,
      int startBufferEvery,
      bool Function(List<S> queue) closeWindowWhen,
      bool ignoreEmptyWindows,
      bool dispatchOnClose) {
    return StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<S> subscription;
      StreamSubscription windowSubscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            var skip = 0;
            // the Queue which is built while a Window frame is open
            final queue = <S>[];
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

                // prepare the buffer for the next window.
                // by default, this is just a cleared buffer
                if (!isControllerClosing && startBufferEvery > 0) {
                  // ...unless startBufferEvery is provided.
                  // here we backtrack to the first event of the last buffer
                  // and count forward using startBufferEvery until we reach
                  // the next event.
                  //
                  // if the next event is found inside the current buffer,
                  // then this event and any later events in the buffer
                  // become the starting values of the next buffer.
                  // if the next event is not yet available, then a skip
                  // count is calculated.
                  // this count will skip the next Future n-events.
                  // when skip is reset to 0, then we start adding events
                  // again into the new buffer.
                  //
                  // example:
                  // startBufferEvery = 2
                  // last buffer: [0, 1, 2, 3, 4]
                  // 0 is the first event,
                  // 2 is the n-th event
                  // new buffer starts with [2, 3, 4]
                  //
                  // example:
                  // startBufferEvery = 3
                  // last buffer: [0, 1]
                  // 0 is the first event,
                  // the n-the event is not yet dispatched at this point
                  // skip becomes 1
                  // event 2 is skipped, skip becomes 0
                  // event 3 is now added to the buffer
                  try {
                    final startWith = (startBufferEvery < queue.length)
                        ? queue.sublist(startBufferEvery)
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

              windowSubscription?.cancel();

              try {
                stream = windowStreamFactory(event);
              } catch (e, s) {
                controller.addError(e, s);
              }

              if (stream == null) {
                controller
                    .addError(ArgumentError.notNull('windowStreamFactory'));
              }

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
                  case WindowStrategy.onHandler:
                    break;
                }
              } catch (e, s) {
                controller.addError(e, s);
              }
            };
            final maybeCloseWindow = () {
              if (closeWindowWhen != null &&
                  closeWindowWhen(UnmodifiableListView(queue))) {
                resolveWindowEnd();
              }
            };
            final onData = (S event) {
              maybeCreateWindow(event);

              if (skip == 0) queue.add(event);

              if (skip > 0) skip--;

              maybeCloseWindow();
            };
            final onDone = () {
              // treat the final event as a Window that opens
              // and immediately closes again
              if (queue.isNotEmpty) resolveWindowStart(queue.last);

              resolveWindowEnd(true);

              queue.clear();
              controller.close();
            };

            subscription = input.listen(onData,
                onError: controller.addError,
                onDone: onDone,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            windowSubscription?.pause(resumeSignal);
            subscription.pause(resumeSignal);
          },
          onResume: () {
            windowSubscription?.resume();
            subscription.resume();
          },
          onCancel: () {
            windowSubscription?.cancel();
            return subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}
