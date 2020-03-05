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
  /// Handler that fires when all subscriptions cancel.
  final dynamic Function() onCancel;

  /// Handler that fires when any subscription cancels.
  final dynamic Function() onCancelAny;

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
      this.onCancelAny,
      this.onData,
      this.onDone,
      this.onEach,
      this.onError,
      this.onListen,
      this.onPause,
      this.onResume}) {
    if (onCancel == null &&
        onCancelAny == null &&
        onData == null &&
        onDone == null &&
        onEach == null &&
        onError == null &&
        onListen == null &&
        onPause == null &&
        onResume == null) {
      throw ArgumentError('Must provide at least one handler');
    }
    ;
  }

  @override
  Stream<T> bind(Stream<T> stream) {
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
          if ((onError != null || onEach != null)) {
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

          controller.close();
        };
    final onCancelHandler = () async {
      if (onCancel != null) {
        FutureOr result = onCancel();

        if (result is Future) {
          return Future.wait<dynamic>([result, subscription.cancel()]);
        }
      }

      return subscription.cancel();
    };

    controller = createController(stream, onListen: () {print('ok');
      subscription =
          _CompositeStream(stream, onCancelAny, onListen, controller.addError)
              .listen(onDataHandler(onData, onEach),
                  onError: onErrorHandler(onError, onEach),
                  onDone: onDoneHandler(onDone, onEach));
    }, onPause: ([Future<dynamic> resumeSignal]) {
      subscription.pause(resumeSignal);

      if (onPause != null) {
        try {
          onPause(resumeSignal);
        } catch (e, s) {
          controller.addError(e, s);
        }
      }
    }, onResume: () {
      subscription.resume();

      if (onResume != null) {
        try {
          onResume();
        } catch (e, s) {
          controller.addError(e, s);
        }
      }
    }, onCancel: onCancelHandler);

    return controller.stream;
  }
}

/// Extends the Stream class with the ability to execute a callback function
/// at different points in the Stream's lifecycle.
extension DoExtensions<T> on Stream<T> {
  /// Invokes the given callback function when all attached stream subscriptions
  /// are cancelled.
  ///
  /// ### Example
  ///     final stream = TimerStream(1, Duration(minutes: 1));
  ///     final subscription = stream
  ///       .doOnCancel(() => print('hi'))
  ///       .listen(null);
  ///
  ///     final subscription2 = TimerStream(1, Duration(minutes: 1))
  ///       .doOnCancel(() => print('hi'))
  ///       .listen(null);
  ///
  ///     subscription.cancel();
  ///     subscription2.cancel(); // prints 'hi'
  Stream<T> doOnCancel(void Function() onCancel) =>
      transform(DoStreamTransformer<T>(onCancel: onCancel));

  /// Invokes the given callback function when the stream subscription is
  /// cancelled. Often called doOnUnsubscribe or doOnDispose in other
  /// implementations.
  ///
  /// ### Example
  ///     final stream = TimerStream(1, Duration(minutes: 1));
  ///     final subscription = stream
  ///       .doOnCancelAny(() => print('hi'))
  ///       .listen(null);
  ///
  ///     final subscription2 = stream
  ///       .doOnCancelAny(() => print('hi'))
  ///       .listen(null);
  ///
  ///     subscription.cancel(); // prints 'hi'
  ///     subscription2.cancel(); // prints 'hi'
  Stream<T> doOnCancelAny(void Function() onCancelAny) =>
      transform(DoStreamTransformer<T>(onCancelAny: onCancelAny));

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

class _CompositeStream<T> implements Stream<T> {
  final Stream<T> _wrappedStream;
  final dynamic Function() _onCancelAny;
  final void Function() _onListen;
  final Function(Object error, [StackTrace stackTrace]) _addError;

  _CompositeStream(
      this._wrappedStream, this._onCancelAny, this._onListen, this._addError);

  @override
  Future<bool> any(bool Function(T element) test) => _wrappedStream.any(test);

  @override
  Stream<T> asBroadcastStream(
          {void Function(StreamSubscription<T> subscription) onListen,
          void Function(StreamSubscription<T> subscription) onCancel}) =>
      _wrappedStream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

  @override
  Stream<E> asyncExpand<E>(Stream<E> Function(T event) convert) =>
      _wrappedStream.asyncExpand(convert);

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(T event) convert) =>
      _wrappedStream.asyncMap(convert);

  @override
  Stream<R> cast<R>() => _wrappedStream.cast<R>();

  @override
  Future<bool> contains(Object needle) => _wrappedStream.contains(needle);

  @override
  Stream<T> distinct([bool Function(T previous, T next) equals]) =>
      _wrappedStream.distinct(equals);

  @override
  Future<E> drain<E>([E futureValue]) => _wrappedStream.drain(futureValue);

  @override
  Future<T> elementAt(int index) => _wrappedStream.elementAt(index);

  @override
  Future<bool> every(bool Function(T element) test) =>
      _wrappedStream.every(test);

  @override
  Stream<S> expand<S>(Iterable<S> Function(T element) convert) =>
      _wrappedStream.expand(convert);

  @override
  Future<T> get first => _wrappedStream.first;

  @override
  Future<T> firstWhere(bool Function(T element) test, {T Function() orElse}) =>
      _wrappedStream.firstWhere(test, orElse: orElse);

  @override
  Future<S> fold<S>(
          S initialValue, S Function(S previous, T element) combine) =>
      _wrappedStream.fold(initialValue, combine);

  @override
  Future forEach(void Function(T element) action) =>
      _wrappedStream.forEach(action);

  @override
  Stream<T> handleError(Function onError, {bool Function(Object error) test}) =>
      _wrappedStream.handleError(onError, test: test);

  @override
  bool get isBroadcast => _wrappedStream.isBroadcast;

  @override
  Future<bool> get isEmpty => _wrappedStream.isEmpty;

  @override
  Future<String> join([String separator = '']) =>
      _wrappedStream.join(separator);

  @override
  Future<T> get last => _wrappedStream.last;

  @override
  Future<T> lastWhere(bool Function(T element) test, {T Function() orElse}) =>
      _wrappedStream.lastWhere(test, orElse: orElse);

  @override
  Future<int> get length => _wrappedStream.length;

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    if (_onListen != null) {
      try {
        _onListen();
      } catch (e, s) {
        _addError(e, s);
      }
    }

    return _CompositeStreamSubscription(
        _wrappedStream.listen(onData,
            onError: onError, onDone: onDone, cancelOnError: cancelOnError),
        _onCancelAny,
        _addError);
  }

  @override
  Stream<S> map<S>(S Function(T event) convert) => _wrappedStream.map(convert);

  @override
  Future pipe(StreamConsumer<T> streamConsumer) =>
      _wrappedStream.pipe(streamConsumer);

  @override
  Future<T> reduce(T Function(T previous, T element) combine) =>
      _wrappedStream.reduce(combine);

  @override
  Future<T> get single => _wrappedStream.single;

  @override
  Future<T> singleWhere(bool Function(T element) test, {T Function() orElse}) =>
      _wrappedStream.singleWhere(test, orElse: orElse);

  @override
  Stream<T> skip(int count) => _wrappedStream.skip(count);

  @override
  Stream<T> skipWhile(bool Function(T element) test) =>
      _wrappedStream.skipWhile(test);

  @override
  Stream<T> take(int count) => _wrappedStream.take(count);

  @override
  Stream<T> takeWhile(bool Function(T element) test) =>
      _wrappedStream.takeWhile(test);

  @override
  Stream<T> timeout(Duration timeLimit,
          {void Function(EventSink<T> sink) onTimeout}) =>
      _wrappedStream.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<T>> toList() => _wrappedStream.toList();

  @override
  Future<Set<T>> toSet() => _wrappedStream.toSet();

  @override
  Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer) =>
      _wrappedStream.transform(streamTransformer);

  @override
  Stream<T> where(bool Function(T event) test) => _wrappedStream.where(test);
}

class _CompositeStreamSubscription<T> implements StreamSubscription<T> {
  final StreamSubscription<T> _wrappedStreamSubscription;
  final dynamic Function() _onCancelAny;
  final Function(Object error, [StackTrace stackTrace]) _addError;

  _CompositeStreamSubscription(
      this._wrappedStreamSubscription, this._onCancelAny, this._addError);

  @override
  Future<E> asFuture<E>([E futureValue]) =>
      _wrappedStreamSubscription.asFuture();

  @override
  Future cancel() {
    if (_onCancelAny != null) {
      try {
        final FutureOr result = _onCancelAny();

        if (result is Future) {
          return Future.wait<dynamic>(
              [result, _wrappedStreamSubscription.cancel()]);
        }
      } catch (e, s) {
        _addError(e, s);
      }
    }

    return _wrappedStreamSubscription.cancel();
  }

  @override
  bool get isPaused => _wrappedStreamSubscription.isPaused;

  @override
  void onData(void Function(T data) handleData) {
    _wrappedStreamSubscription.onData(handleData);
  }

  @override
  void onDone(void Function() handleDone) {
    _wrappedStreamSubscription.onDone(handleDone);
  }

  @override
  void onError(Function handleError) {
    _wrappedStreamSubscription.onError(handleError);
  }

  @override
  void pause([Future resumeSignal]) =>
      _wrappedStreamSubscription.pause(resumeSignal);

  @override
  void resume() => _wrappedStreamSubscription.resume();
}
