import 'dart:async';

import 'dart:collection';

class BackpressureStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  BackpressureStreamTransformer(Stream<dynamic> windowStreamFactory(T event),
      T onWindowStart(T event), T onWindowEnd(Queue<T> queue),
      {bool ignoreEmptyWindows = true})
      : transformer = _buildTransformer(windowStreamFactory, onWindowStart,
            onWindowEnd, ignoreEmptyWindows);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Stream<dynamic> windowStreamFactory(T event),
      T onWindowStart(T event),
      T onWindowEnd(Queue<T> queue),
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
              windowSubscription?.cancel();
              windowSubscription = null;

              if (queue.isNotEmpty || !ignoreEmptyWindows) {
                if (onWindowEnd != null) controller.add(onWindowEnd(queue));

                queue.clear();
              }
            };
            final maybeCreateWindow = (T event) {
              if (windowSubscription != null) return;

              if (onWindowStart != null) controller.add(onWindowStart(event));

              windowSubscription = windowStreamFactory(event).listen(null,
                  onError: controller.addError, onDone: resolveWindowEnd);
            };

            subscription = input.listen(
                (event) {
                  maybeCreateWindow(event);
                  queue.add(event);
                },
                onError: controller.addError,
                onDone: () {
                  onWindowEnd =
                      (Queue<T> queue) => queue.isNotEmpty ? queue.last : null;
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
