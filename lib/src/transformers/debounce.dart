import 'dart:async';

import 'package:rxdart/src/streams/timer.dart';

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
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription, innerSubscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            _EventWrapper<T> wrappedEvent;

            subscription = input.listen(
                (T value) {
                  wrappedEvent = _EventWrapper(value);

                  try {
                    innerSubscription?.cancel();

                    innerSubscription = TimerStream(value, duration).listen(
                        controller.add,
                        onError: controller.addError,
                        onDone: () => wrappedEvent = null);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  if (wrappedEvent != null) {
                    scheduleMicrotask(() {
                      innerSubscription?.cancel();

                      controller
                        ..add(wrappedEvent.event)
                        ..close();
                    });
                  } else {
                    controller.close();
                  }
                },
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            subscription.pause(resumeSignal);
            innerSubscription?.pause(resumeSignal);
          },
          onResume: () {
            subscription.resume();
            innerSubscription?.resume();
          },
          onCancel: () {
            innerSubscription?.cancel();

            return subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}

/// Inner wrapper class.
/// Because the event can be of value null, checking on != null in the code
/// above is ambiguous.
/// If we wrap the event, then the inner value can safely be null.
class _EventWrapper<T> {
  final T event;

  _EventWrapper(this.event);
}
