import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'errors.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the previous and current `value` and is responsible for
/// executing in response to `value` changes.
typedef ValueStreamWidgetListener<T> = void Function(
  BuildContext context,
  T previous,
  T current,
);

/// {@template value_stream_listener}
/// Takes a [ValueStreamWidgetListener] and a [stream] and invokes
/// the [listener] in response to `value` changes in the [stream].
///
/// It should be used for functionality that needs to occur only in response to
/// a `value` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
///
/// The [listener] is guaranteed to only be called once for each `value` change
/// unlike the `builder` in `ValueStreamBuilder`.
///
/// [ValueStreamListener] requires [stream.hasValue] to always be `true`,
/// and the [stream] does not emit any error events.
/// See [ValueStreamHasNoValueError] and [UnhandledStreamError]
/// for more information.
///
/// **Example**
///
/// ```dart
/// ValueStreamListener<T>(
///   stream: valueStream,
///   listener: (context, previous, current) {
///     // do stuff here based on valueStream's
///     // previous and current values
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class ValueStreamListener<T> extends StatefulWidget {
  /// {@macro value_stream_listener}
  const ValueStreamListener({
    Key? key,
    required this.stream,
    required this.listener,
    required this.child,
    this.isReplayValueStream,
  }) : super(key: key);

  /// The [ValueStream] that the [ValueStreamListener] will interact with.
  final ValueStream<T> stream;

  /// Takes the `BuildContext` along with the `previous` and `current` values
  /// and is responsible for executing in response to `value` changes.
  final ValueStreamWidgetListener<T> listener;

  /// The widget which will be rendered as a descendant of the
  /// [ValueStreamListener].
  final Widget child;

  /// Whether or not the [stream] re-emits the last value to new listeners
  /// like [BehaviorSubject] does.
  /// See [ValueStream.isReplayValueStream] for more information.
  ///
  /// If this argument is `null`, the [ValueStream.isReplayValueStream] is used instead.
  ///
  /// Defaults to `null`.
  final bool? isReplayValueStream;

  @override
  State<ValueStreamListener<T>> createState() => _ValueStreamListenerState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueStream<T>>('stream', stream))
      ..add(DiagnosticsProperty<bool>('isReplayValueStream',
          isReplayValueStream ?? stream.isReplayValueStream))
      ..add(ObjectFlagProperty<ValueStreamWidgetListener<T>>.has(
          'listener', listener))
      ..add(ObjectFlagProperty<Widget>.has('child', child));
  }
}

class _ValueStreamListenerState<T> extends State<ValueStreamListener<T>> {
  /// Active subscription to the current stream. Null when not listening.
  StreamSubscription<T>? _subscription;

  /// Tracks the last value notified to the listener.
  /// Used to derive the `previous` argument in [ValueStreamWidgetListener].
  late T _currentValue;

  /// Non-null when the stream fails validation (e.g. no initial value)
  /// or emits an error. Causes [build] to render an [ErrorWidget].
  ErrorAndStackTrace? _error;

  /// True once the subscription's listen callback has delivered at least one
  /// event for the current stream. Used to skip the synthetic post-frame
  /// notification when a real event has already been delivered — avoids a
  /// spurious listener call where previous == current.
  bool _hasReceivedEvent = false;

  /// Becomes true after the first successful subscribe setup.
  ///
  /// While false: seed [_currentValue] from `stream.value` and skip synthetic
  /// notifications.
  ///
  /// While true: keep old [_currentValue] as `previous` when switching streams,
  /// and for non-replay streams schedule the synthetic post-frame notification.
  bool _hasSubscribedSuccessfully = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant ValueStreamListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      // Stream instance changed → tear down old subscription,
      // then set up a new one for the new stream.
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  /// Core subscription logic. Handles two stream kinds differently:
  ///
  /// **Replay stream** (e.g. BehaviorSubject):
  ///   Re-emits latest value on listen. On first subscribe (initState),
  ///   skip(1) to avoid a duplicate notification for the seed value
  ///   we already captured in _currentValue. On stream change
  ///   (didUpdateWidget), skip nothing — the replayed value IS the
  ///   synthetic "value changed" notification we need.
  ///
  /// **Non-replay stream**:
  ///   Does NOT re-emit on listen, so we subscribe immediately to avoid
  ///   missing any events. When the stream is swapped after at least one
  ///   successful subscribe, we also schedule a post-frame callback to
  ///   synthetically notify the listener about the new stream's current
  ///   value (since it won't be re-emitted). The callback includes a
  ///   staleness guard: if widget.stream changed again before the callback
  ///   fires, bail out.
  void _subscribe() {
    // Capture stream reference at schedule time for staleness comparison.
    final stream = widget.stream;

    _error = validateValueStreamInitialValue(stream);
    if (_error != null) {
      return;
    }

    final hasSuccessfulSubscriptionBefore = _hasSubscribedSuccessfully;

    // First subscription: seed _currentValue from the stream's current value.
    // On subsequent calls (stream changed), we intentionally keep the old
    // _currentValue so the listener receives the correct `previous` argument.
    if (!hasSuccessfulSubscriptionBefore) {
      _currentValue = stream.value;
    }

    if (widget.isReplayValueStream ?? stream.isReplayValueStream) {
      // Replay stream re-emits its latest value on listen.
      //
      // First subscribe (initState): skip(1) — we already seeded
      //   _currentValue from stream.value above, so the replayed value
      //   would be a duplicate (previous == current).
      //
      // Stream changed (didUpdateWidget): no skip — the replayed value
      //   IS the notification we need (previous = old stream's value,
      //   current = new stream's replayed value).
      _subscribeIfNeeded(
        !hasSuccessfulSubscriptionBefore ? stream.skip(1) : stream,
      );
    } else {
      // Non-replay stream: subscribe immediately so no events are dropped.
      _subscribeIfNeeded(stream);

      if (hasSuccessfulSubscriptionBefore) {
        // Stream was swapped via didUpdateWidget. The new stream won't
        // re-emit its current value, so we fire a synthetic notification
        // in a post-frame callback (can't call listener during build phase).
        _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
          // Guard: widget was disposed between scheduling and execution.
          if (!mounted) {
            return;
          }
          // Staleness guard: if the stream changed again between scheduling
          // and execution of this callback, skip — a newer _subscribe() call
          // will handle it.
          if (widget.stream != stream) {
            return;
          }
          // Skip if a real event already arrived via the subscription
          // (avoids a spurious call where previous == current).
          if (_hasReceivedEvent) {
            return;
          }
          _notifyListener(stream.value);
        });
      }
    }

    // Only mark as subscribed after validation has passed and subscription
    // logic has been set up successfully.
    _hasSubscribedSuccessfully = true;
  }

  /// Subscribes to [streamToListen] only if there is no active subscription.
  /// This is a guard against double-subscribe, NOT a stream-identity check —
  /// callers ensure the old subscription is cancelled (via [_unsubscribe])
  /// before calling [_subscribe] when the stream changes.
  void _subscribeIfNeeded(Stream<T> streamToListen) {
    if (_subscription != null) {
      return;
    }
    _hasReceivedEvent = false;
    _subscription = streamToListen.listen(
      (value) {
        if (!mounted) return;
        _hasReceivedEvent = true;
        _notifyListener(value);
      },
      onError: (Object e, StackTrace s) {
        if (!mounted) return;
        _error = ErrorAndStackTrace(UnhandledStreamError(e), s);
        reportError(_error!);
        setState(() {});
      },
    );
  }

  /// Invokes the listener with the previous and new value,
  /// and updates [_currentValue] for the next comparison.
  void _notifyListener(T value) {
    final previousValue = _currentValue;
    _currentValue = value;
    widget.listener(context, previousValue, value);
  }

  /// Cancels the current subscription and clears the reference.
  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorWidget(_error!.error);
    }
    return widget.child;
  }
}

/// Reference: https://docs.flutter.dev/release/release-notes/release-notes-3.0.0#your-code
///
/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;
