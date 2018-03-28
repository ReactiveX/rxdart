import 'dart:async';

/// Transforms a Stream so that will only emit items from the source sequence
/// if a particular time span has passed without the source sequence emitting
/// another item.
///
/// The Debounce Transformer filters out items emitted by the source Observable
/// that are rapidly followed by another emitted item.
///
/// [Interactive marble diagram](http://rxmarbles.com/#debounce)
///
/// ### Example
///
///     new Observable.fromIterable([1, 2, 3, 4])
///       .debounce(new Duration(seconds: 1))
///       .listen(print); // prints 4
class DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  DebounceStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      T lastEvent;
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      Timer timer;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  lastEvent = value;

                  try {
                    _cancelTimerIfActive(timer);

                    timer = new Timer(duration, () {
                      controller.add(lastEvent);
                      lastEvent = null;
                    });
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  _cancelTimerIfActive(timer);

                  if (lastEvent != null) {
                    scheduleMicrotask(() {
                      controller.add(lastEvent);

                      controller.close();
                    });
                  } else {
                    controller.close();
                  }
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () {
            _cancelTimerIfActive(timer);

            return subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }

  static void _cancelTimerIfActive(Timer _timer) {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
  }
}
