import 'dart:async';

import 'package:rxdart/src/utils/notification.dart';

/// Invokes the given callback at the corresponding point the the stream
/// lifecycle. For example, if you pass in an onDone callback, it will
/// be invoked when the stream finishes emitting items.
///
/// This transformer can be used for debugging, logging, etc. by intercepting
/// the stream at different points to run arbitrary actions.
///
/// It is possible to hook onto the following parts of the stream lifecycle:
///
///   - onCancel
///   - onData
///   - onDone
///   - onError
///   - onListen
///   - onPause
///   - onResume
///
/// In addition, the `onEach` argument is called at `onData`, `onDone`, and
/// `onError` with a [Notification] passed in. The [Notification] argument
/// contains the [Kind] of event (OnData, OnDone, OnError), and the item or
/// error that was emitted. In the case of onDone, no data is emitted as part
/// of the [Notification].
///
/// If no callbacks are passed in, a runtime error will be thrown in dev mode
/// in order to 'fail fast' and alert the developer that the transformer should
/// be used or safely removed.
///
/// ### Example
///
///     Stream.fromIterable([1])
///         .transform(DoStreamTransformer(
///           onData: print,
///           onError: (e, s) => print('Oh no!'),
///           onDone: () => print('Done')))
///         .listen(null); // Prints: 1, 'Done'
class DoStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which will trigger any of the provided
  /// handlers as they occur.
  DoStreamTransformer(
      {dynamic Function() onCancel,
      void Function(T event) onData,
      void Function() onDone,
      void Function(Notification<T> notification) onEach,
      Function onError,
      void Function() onListen,
      void Function(Future<dynamic> resumeSignal) onPause,
      void Function() onResume})
      : _transformer = _buildTransformer(
            onCancel: onCancel,
            onData: onData,
            onDone: onDone,
            onEach: onEach,
            onError: onError,
            onListen: onListen,
            onPause: onPause,
            onResume: onResume);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      {dynamic Function() onCancel,
      void Function(T event) onData,
      void Function() onDone,
      void Function(Notification<T> notification) onEach,
      Function onError,
      void Function() onListen,
      void Function(Future<dynamic> resumeSignal) onPause,
      void Function() onResume}) {
    if (onCancel == null &&
        onData == null &&
        onDone == null &&
        onEach == null &&
        onError == null &&
        onListen == null &&
        onPause == null &&
        onResume == null) {
      throw ArgumentError('Must provide at least one handler');
    }

    final subscriptions = <Stream<dynamic>, StreamSubscription<dynamic>>{};

    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamController<T> controller;
      final onListenLocal = () {
        if (onListen != null) {
          try {
            onListen();
          } catch (e, s) {
            controller.addError(e, s);
          }
        }
        subscriptions.putIfAbsent(
          input,
          () => input.listen(
            (T value) {
              if (onData != null) {
                try {
                  onData(value);
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
              if (onEach != null) {
                try {
                  onEach(Notification<T>.onData(value));
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
              controller.add(value);
            },
            onError: (dynamic e, StackTrace s) {
              if (onError != null) {
                try {
                  onError(e, s);
                } catch (e2, s2) {
                  controller.addError(e2, s2);
                }
              }
              if (onEach != null) {
                try {
                  onEach(Notification<T>.onError(e, s));
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
              controller.addError(e, s);
            },
            onDone: () {
              if (onDone != null) {
                try {
                  onDone();
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
              if (onEach != null) {
                try {
                  onEach(Notification<T>.onDone());
                } catch (e, s) {
                  controller.addError(e, s);
                }
              }
              controller.close();
            },
            cancelOnError: cancelOnError,
          ),
        );
      };
      final onCancelLocal = () {
        dynamic onCancelResult;

        if (onCancel != null) {
          try {
            onCancelResult = onCancel();
          } catch (e, s) {
            if (!controller.isClosed) {
              controller.addError(e, s);
            } else {
              Zone.current.handleUncaughtError(e, s);
            }
          }
        }
        final cancelResultFuture = onCancelResult is Future
            ? onCancelResult
            : Future<dynamic>.value(onCancelResult);
        final cancelFuture =
            subscriptions[input].cancel() ?? Future<dynamic>.value();

        return Future.wait<dynamic>([cancelFuture, cancelResultFuture])
            .whenComplete(() => subscriptions.remove(input));
      };

      if (input.isBroadcast) {
        controller = StreamController<T>.broadcast(
          sync: true,
          onListen: onListenLocal,
          onCancel: onCancelLocal,
        );
      } else {
        controller = StreamController<T>(
          sync: true,
          onListen: onListenLocal,
          onCancel: onCancelLocal,
          onPause: ([Future<dynamic> resumeSignal]) {
            if (onPause != null) {
              try {
                onPause(resumeSignal);
              } catch (e, s) {
                controller.addError(e, s);
              }
            }

            subscriptions[input].pause(resumeSignal);
          },
          onResume: () {
            if (onResume != null) {
              try {
                onResume();
              } catch (e, s) {
                controller.addError(e, s);
              }
            }

            subscriptions[input].resume();
          },
        );
      }

      return controller.stream.listen(null);
    });
  }
}

/// Extends the Stream class with the ability to execute a callback function
/// at different points in the Stream's lifecycle.
extension DoExtensions<T> on Stream<T> {
  /// Invokes the given callback function when the stream subscription is
  /// cancelled. Often called doOnUnsubscribe or doOnDispose in other
  /// implementations.
  ///
  /// ### Example
  ///
  ///     final subscription = TimerStream(1, Duration(minutes: 1))
  ///       .doOnCancel(() => print('hi'));
  ///       .listen(null);
  ///
  ///     subscription.cancel(); // prints 'hi'
  Stream<T> doOnCancel(void Function() onCancel) =>
      transform(DoStreamTransformer<T>(onCancel: onCancel));

  /// Invokes the given callback function when the stream emits an item. In
  /// other implementations, this is called doOnNext.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .doOnData(print)
  ///       .listen(null); // prints 1, 2, 3
  Stream<T> doOnData(void Function(T event) onData) =>
      transform(DoStreamTransformer<T>(onData: onData));

  /// Invokes the given callback function when the stream finishes emitting
  /// items. In other implementations, this is called doOnComplete(d).
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .doOnDone(() => print('all set'))
  ///       .listen(null); // prints 'all set'
  Stream<T> doOnDone(void Function() onDone) =>
      transform(DoStreamTransformer<T>(onDone: onDone));

  /// Invokes the given callback function when the stream emits data, emits
  /// an error, or emits done. The callback receives a [Notification] object.
  ///
  /// The [Notification] object contains the [Kind] of event (OnData, onDone,
  /// or OnError), and the item or error that was emitted. In the case of
  /// onDone, no data is emitted as part of the [Notification].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///       .doOnEach(print)
  ///       .listen(null); // prints Notification{kind: OnData, value: 1, errorAndStackTrace: null}, Notification{kind: OnDone, value: null, errorAndStackTrace: null}
  Stream<T> doOnEach(void Function(Notification<T> notification) onEach) =>
      transform(DoStreamTransformer<T>(onEach: onEach));

  /// Invokes the given callback function when the stream emits an error.
  ///
  /// ### Example
  ///
  ///     Stream.error(Exception())
  ///       .doOnError((error, stacktrace) => print('oh no'))
  ///       .listen(null); // prints 'Oh no'
  Stream<T> doOnError(Function onError) =>
      transform(DoStreamTransformer<T>(onError: onError));

  /// Invokes the given callback function when the stream is first listened to.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///       .doOnListen(() => print('Is someone there?'))
  ///       .listen(null); // prints 'Is someone there?'
  Stream<T> doOnListen(void Function() onListen) =>
      transform(DoStreamTransformer<T>(onListen: onListen));

  /// Invokes the given callback function when the stream subscription is
  /// paused.
  ///
  /// ### Example
  ///
  ///     final subscription = Stream.fromIterable([1])
  ///       .doOnPause(() => print('Gimme a minute please'))
  ///       .listen(null);
  ///
  ///     subscription.pause(); // prints 'Gimme a minute please'
  Stream<T> doOnPause(void Function(Future<dynamic> resumeSignal) onPause) =>
      transform(DoStreamTransformer<T>(onPause: onPause));

  /// Invokes the given callback function when the stream subscription
  /// resumes receiving items.
  ///
  /// ### Example
  ///
  ///     final subscription = Stream.fromIterable([1])
  ///       .doOnResume(() => print('Let's do this!'))
  ///       .listen(null);
  ///
  ///     subscription.pause();
  ///     subscription.resume(); 'Let's do this!'
  Stream<T> doOnResume(void Function() onResume) =>
      transform(DoStreamTransformer<T>(onResume: onResume));
}
