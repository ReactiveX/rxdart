import 'dart:async';

import 'package:rxdart/src/utils/controller.dart';
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
  /// Handler that fires when cancel occurs.
  final dynamic Function() onCancel;
  /// Handler that fires when an event dispatches.
  final void Function(T event) onData;
  /// Handler that fires when the [Stream] closes.
  final void Function() onDone;
  /// Handler that fires on any event (cancel, data, done, error, listen, pause and resume).
  final void Function(Notification<T> notification) onEach;
  /// Handler that fires when an error occurs.
  final Function onError;
  /// Handler that fires when a new subscription occurs.
  final void Function() onListen;
  /// Handler that fires when pause occurs.
  final void Function(Future<dynamic> resumeSignal) onPause;
  /// Handler that fires when resume occurs.
  final void Function() onResume;

  /// Constructs a [StreamTransformer] which will trigger any of the provided
  /// handlers as they occur.
  DoStreamTransformer(
      {this.onCancel,
      this.onData,
      this.onDone,
      this.onEach,
      this.onError,
      this.onListen,
      this.onPause,
      this.onResume}) {
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
  }

  @override
  Stream<T> bind(Stream<T> stream) {
    // Keep track of emitted Errors
    // This Set is checked when an Error happens,
    // if it does not yet contain the Error, then emit it,
    // otherwise do nothing.
    //
    // This will prevent multiple listeners to the same Stream to emit
    // onError with the same error multiple times.
    final emittedErrors = <Object>{};
    final onDataManifest = <Stream<T>>[];

    StreamSubscription<T> subscription;
    StreamController<T> controller;

    final onEachHandler = (Notification<T> notification) {
      try {
        onEach(notification);
      } catch (e, s) {
        controller.addError(e, s);
      }
    };
    final onDataHandler = (void Function(T event) onData,
            void Function(Notification<T> notification) onEach) =>
        (T event) {
          if ((onData != null || onEach != null)) {
            if (onData != null) {
              try {
                onData(event);
              } catch (e, s) {
                controller.addError(e, s);
              }
            }

            if (onEach != null) {
              onEachHandler(Notification.onData(event));
            }
          }

          controller.add(event);
        };
    ;
    final onErrorHandler = (Function onError,
            void Function(Notification<T> notification) onEach) =>
        (Object e, StackTrace s) {
          if ((onError != null || onEach != null) && emittedErrors.add(e)) {
            if (onError != null) {
              try {
                onError(e, s);
              } catch (e, s) {
                controller.addError(e, s);
              }
            }

            if (onEach != null) {
              onEachHandler(Notification.onError(e, s));
            }
          }

          controller.addError(e);
        };
    final onCancelHandler = () async {
      if (onCancel != null) {
        dynamic result = onCancel();

        if (result is Future) {
          return Future.wait<dynamic>([result, subscription.cancel()]);
        }
      }

      return subscription.cancel();
    };
    final onDoneHandler = (void Function() onDone,
            void Function(Notification<T> notification) onEach) =>
        () {
          if (onDone != null) {
            try {
              onDone();
            } catch (e, s) {
              controller.addError(e, s);
            }
          }

          if (onEach != null) {
            onEachHandler(Notification.onDone());
          }

          onDataManifest.clear();

          controller.close();
        };
    final onListenDelegate = () {
      if (onListen != null) {
        try {
          onListen();
        } catch (e, s) {
          controller.addError(e, s);
        }
      }

      // checks if this input Stream is already handling onX...
      final isOnXHandled = onDataManifest.contains(stream);
      final maybeOnData = isOnXHandled ? null : onData;
      final maybeOnError = isOnXHandled ? null : onError;
      final maybeOnDone = isOnXHandled ? null : onDone;
      final maybeOnEach = isOnXHandled ? null : onEach;
      // ...and if it does, pass null handlers to the onX handler,
      // resulting in this onX pass to be ignored
      subscription = stream.listen(onDataHandler(maybeOnData, maybeOnEach),
          onError: onErrorHandler(maybeOnError, maybeOnEach),
          onDone: onDoneHandler(maybeOnDone, maybeOnEach));

      // because we want to prevent duplicate onX handling
      // for the same input Stream, a List is being kept of all
      // Streams that already do onX handling
      onDataManifest.add(stream);
    };

    controller = createController(stream,
        onListen: onListenDelegate,
        onPause: ([Future<dynamic> resumeSignal]) {
          subscription.pause(resumeSignal);

          if (onPause != null) {
            try {
              onPause(resumeSignal);
            } catch (e, s) {
              controller.addError(e, s);
            }
          }
        },
        onResume: () {
          subscription.resume();

          if (onResume != null) {
            try {
              onResume();
            } catch (e, s) {
              controller.addError(e, s);
            }
          }
        },
        onCancel: onCancelHandler);

    return controller.stream;
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
