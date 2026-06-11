import 'dart:async';

import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';
import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/future.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
Stream<R> forwardStream<T, R>(
  Stream<T> stream,
  ForwardingSink<T, R> Function() sinkFactory, {
  bool sideEffectsOnce = false,
}) {
  if (stream.isBroadcast) {
    // [sideEffectsOnce] is only used by [DoStreamTransformer] (doOn*). It must
    // satisfy two goals at once:
    //
    // 1. Side-effect callbacks (doOnData, doOnError, …) run at most once per
    //    upstream event, even with multiple concurrent listeners.
    // 2. The transformed stream still behaves like the source: every listen
    //    subscribes to the upstream (so replay sources such as [BehaviorSubject]
    //    keep delivering their current value on each new subscription).
    //
    // Fixes #605 and #657, where a single shared upstream subscription broke
    // [Stream.first] and re-subscribe after cancel on replay streams.
    if (sideEffectsOnce) {
      assert(
        T == R,
        'sideEffectsOnce is only supported when input and output types match '
        '(used by DoStreamTransformer).',
      );
      return _forwardMultiSideEffectsOnce(
        stream as Stream<R>,
        sinkFactory as ForwardingSink<R, R> Function(),
      );
    }
    return _forwardMulti(stream, sinkFactory);
  }
  return _forward(stream, sinkFactory);
}

/// Broadcast forwarding for [DoStreamTransformer].
///
/// Unlike a single shared upstream subscription, each [Stream.multi] listener
/// calls [Stream.listen] on the source so the output mirrors normal broadcast
/// semantics (including replay from [ValueStream] sources on every listen).
///
/// Side effects must not run once per listener though. The chronologically
/// first active listener (tracked via [controllers]) is the "primary" and
/// routes events through [ForwardingSink.onData], which invokes doOn*
/// callbacks. Additional listeners bypass [onData] and write directly to
/// [ForwardingSink.sink], so they still receive events without re-firing
/// side effects.
Stream<T> _forwardMultiSideEffectsOnce<T>(
    Stream<T> stream, ForwardingSink<T, T> Function() sinkFactory) {
  final controllers = <StreamController<T>>[];
  return Stream<T>.multi((controller) {
    final sink = sinkFactory();
    sink.setSink(_MultiControllerSink(controller));

    StreamSubscription<T>? subscription;
    var cancelled = false;

    void listenToUpstream([void _]) {
      if (cancelled) {
        return;
      }
      subscription = stream.listen(
        (v) {
          if (controllers.first == controller) {
            sink.onData(v);
          } else {
            // This listener has its own upstream subscription (source semantics),
            // but side effects already ran on the primary listener's path.
            sink.sink.add(v);
          }
        },
        onError: (Object e, StackTrace s) {
          if (controllers.first == controller) {
            sink.onError(e, s);
          } else {
            sink.sink.addError(e, s);
          }
        },
        onDone: () {
          if (controllers.first == controller) {
            sink.onDone();
          } else {
            sink.sink.close();
          }
        },
      );
      sink.setSubscription(subscription);
    }

    controllers.add(controller);

    // doOnListen / doOnCancel fire once for the transformed stream, not per
    // listener — while each listen above still subscribes to the source.
    final futureOrVoid =
        controllers.first == controller ? sink.onListen() : null;
    if (futureOrVoid is Future<void>) {
      futureOrVoid.then(listenToUpstream).onError<Object>((e, s) {
        if (!cancelled && !controller.isClosed) {
          controller.addError(e, s);
          controller.close();
        }
      });
    } else {
      listenToUpstream();
    }

    controller.onCancel = () {
      controllers.remove(controller);

      cancelled = true;

      final future = subscription?.cancel();
      subscription = null;
      sink.setSubscription(null);

      return waitTwoFutures(
        future,
        // Defer onCancel until the last listener has unsubscribed.
        controllers.isEmpty ? sink.onCancel() : Future.value(),
      );
    };
  }, isBroadcast: true);
}

Stream<R> _forwardMulti<T, R>(
    Stream<T> stream, ForwardingSink<T, R> Function() sinkFactory) {
  return Stream<R>.multi((controller) {
    final sink = sinkFactory();
    sink.setSink(_MultiControllerSink(controller));

    StreamSubscription<T>? subscription;
    var cancelled = false;

    void listenToUpstream([void _]) {
      if (cancelled) {
        return;
      }
      subscription = stream.listen(
        sink.onData,
        onError: sink.onError,
        onDone: sink.onDone,
      );
      sink.setSubscription(subscription);
    }

    final futureOrVoid = sink.onListen();
    if (futureOrVoid is Future<void>) {
      futureOrVoid.then(listenToUpstream).onError<Object>((e, s) {
        if (!cancelled && !controller.isClosed) {
          controller.addError(e, s);
          controller.close();
        }
      });
    } else {
      listenToUpstream();
    }

    controller.onCancel = () {
      cancelled = true;

      final future = subscription?.cancel();
      subscription = null;
      sink.setSubscription(null);

      return waitTwoFutures(future, sink.onCancel());
    };
  }, isBroadcast: true);
}

Stream<R> _forward<T, R>(
  Stream<T> stream,
  ForwardingSink<T, R> Function() sinkFactory,
) {
  final controller = stream.isBroadcast
      ? StreamController<R>.broadcast(sync: true)
      : StreamController<R>(sync: true);

  StreamSubscription<T>? subscription;
  var cancelled = false;
  late final sink = sinkFactory();

  controller.onListen = () {
    cancelled = false;
    void listenToUpstream([void _]) {
      if (cancelled) {
        return;
      }
      subscription = stream.listen(
        sink.onData,
        onError: sink.onError,
        onDone: sink.onDone,
      );
      sink.setSubscription(subscription);

      if (!stream.isBroadcast) {
        controller.onPause = () {
          subscription!.pause();
          sink.onPause();
        };
        controller.onResume = () {
          subscription!.resume();
          sink.onResume();
        };
      }
    }

    sink.setSink(_EnhancedEventSink(controller));
    final futureOrVoid = sink.onListen();
    if (futureOrVoid is Future<void>) {
      futureOrVoid.then(listenToUpstream).onError<Object>((e, s) {
        if (!cancelled && !controller.isClosed) {
          controller.addError(e, s);
          controller.close();
        }
      });
    } else {
      listenToUpstream();
    }
  };
  controller.onCancel = () {
    cancelled = true;

    final future = subscription?.cancel();
    subscription = null;
    sink.setSubscription(null);

    return waitTwoFutures(future, sink.onCancel());
  };
  return controller.stream;
}

class _MultiControllerSink<T> implements EventSink<T>, EnhancedEventSink<T> {
  final MultiStreamController<T> controller;

  _MultiControllerSink(this.controller);

  @override
  void add(T event) => controller.addSync(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      controller.addErrorSync(error, stackTrace);

  @override
  void close() => controller.closeSync();

  @override
  bool get isPaused => controller.isPaused;
}

class _EnhancedEventSink<T> implements EnhancedEventSink<T> {
  final StreamController<T> _controller;

  _EnhancedEventSink(this._controller);

  @override
  void add(T event) => _controller.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _controller.addError(error, stackTrace);

  @override
  void close() => _controller.close();

  @override
  bool get isPaused => _controller.isPaused;
}
