import 'dart:async';

/// A StreamTransformer that emits only the first item emitted by the source
/// Stream during sequential time windows of a specified duration.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3])
///       .transform(new ThrottleStreamTransformer(new Duration(seconds: 1)))
///       .listen(print); // prints 1
class ThrottleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  ThrottleStreamTransformer(Duration duration, {bool trailing = false})
      : transformer = _buildTransformer(duration, trailing: trailing);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration,
      {bool trailing = false}) {
    assert(duration != null, 'duration cannot be null');

    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription, windowSubscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            T last;

            final resolveNext = (T event) {
              if (windowSubscription == null) {
                controller.add(event);

                windowSubscription = _window(duration)
                    .listen(null, onError: controller.addError, onDone: () {
                  windowSubscription.cancel();
                  windowSubscription = null;
                  last = null;
                }, cancelOnError: cancelOnError);
              } else {
                last = event;
              }
            };

            subscription = input
                .listen(resolveNext, onError: controller.addError, onDone: () {
              windowSubscription?.cancel();

              if (last != null) {
                scheduleMicrotask(() {
                  controller
                    ..add(last)
                    ..close();
                });
              } else {
                controller.close();
              }
            }, cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            subscription.pause(resumeSignal);
            windowSubscription?.pause(resumeSignal);
          },
          onResume: () {
            subscription.resume();
            windowSubscription?.resume();
          },
          onCancel: () {
            windowSubscription?.cancel();

            return subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}

Stream<Null> _window(Duration duration) async* {
  yield await Future.delayed(duration);
}
