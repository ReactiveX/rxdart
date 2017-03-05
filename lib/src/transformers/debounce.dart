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
///     new Stream.fromIterable([1, 2, 3, 4])
///       .transform(new DebounceStreamTransformer(new Duration(seconds: 1)))
///       .listen(print); // prints 4
class DebounceStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;

  DebounceStreamTransformer(Duration duration)
      : transformer = _buildTransformer(duration);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(Duration duration) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;
      bool _closeAfterNextEvent = false;
      Timer _timer;
      bool streamHasEvent = false;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  streamHasEvent = true;

                  if (_timer != null && _timer.isActive) _timer.cancel();

                  _timer = new Timer(duration, () {
                    controller.add(value);

                    if (_closeAfterNextEvent) controller.close();
                  });
                },
                onError: controller.addError,
                onDone: () {
                  if (!streamHasEvent)
                    controller.close();
                  else
                    _closeAfterNextEvent = true;
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
