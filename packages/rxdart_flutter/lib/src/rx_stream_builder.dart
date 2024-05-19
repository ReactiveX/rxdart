import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

bool _defaultBuildWhen(Object? previous, Object? current) =>
    previous != current;

/// Signature for strategies that build widgets based on asynchronous interaction.
typedef RxWidgetBuilder<T> = Widget Function(BuildContext context, T data);

/// Signature for the `initialData` function which takes no arguments and returns
/// the initial data in case the stream has no value.
typedef InitialData<T> = T Function();

/// Signature for the `buildWhen` function which takes the previous `data` and
/// the current `data` and is responsible for returning a [bool] which
/// determines whether to rebuild [ValueStream] with the current `data`.
typedef RxStreamBuilderCondition<S> = bool Function(S previous, S current);

/// Rx stream builder that will pre-populate the streams initial data if the
/// given stream is an stream that holds the streams current value such
/// as a [ValueStream] or a [ReplayStream]
class RxStreamBuilder<T> extends StatefulWidget {
  final RxWidgetBuilder<T> _builder;
  final ValueStream<T> _stream;
  final InitialData<T>? _initialData;
  final RxStreamBuilderCondition<T>? _buildWhen;

  /// Creates a new [RxStreamBuilder] that builds itself based on the latest
  /// snapshot of interaction with the specified [stream] and whose build
  /// strategy is given by [builder].
  ///
  /// The [initialData] is used to create the initial snapshot.
  /// See [StreamBuilder.initialData].
  ///
  /// The [builder] must not be null. It must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  const RxStreamBuilder({
    Key? key,
    required ValueStream<T> stream,
    required RxWidgetBuilder<T> builder,
    InitialData<T>? initialData,
    RxStreamBuilderCondition<T>? buildWhen,
  })  : _builder = builder,
        _stream = stream,
        _initialData = initialData,
        _buildWhen = buildWhen,
        super(key: key);

  @override
  State<RxStreamBuilder<T>> createState() => _RxStreamBuilderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueStream<T>>('stream', _stream))
      ..add(ObjectFlagProperty<RxWidgetBuilder<T>>.has('builder', _builder))
      ..add(
        ObjectFlagProperty<RxStreamBuilderCondition<T>?>.has(
          'buildWhen',
          _buildWhen,
        ),
      )
      ..add(
        ObjectFlagProperty<InitialData<T>?>.has(
          'initialData',
          _initialData,
        ),
      );
  }

  /// Get latest value from stream or throw an [ArgumentError].
  @visibleForTesting
  static T getInitialData<T>(
      ValueStream<T> stream, InitialData<T>? initialData) {
    if (stream.hasValue) {
      return stream.value;
    }
    if (initialData != null) {
      return initialData();
    }
    throw ArgumentError.value(stream, 'stream', 'has no value');
  }
}

class _RxStreamBuilderState<T> extends State<RxStreamBuilder<T>> {
  late T currentData;
  StreamSubscription<T>? subscription;

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void didUpdateWidget(covariant RxStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._stream != widget._stream) {
      unsubscribe();
      subscribe();
    }
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget._builder(context, currentData);

  void subscribe() {
    final stream = widget._stream;

    try {
      currentData = RxStreamBuilder.getInitialData(stream, widget._initialData);
    } catch (e) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: StackTrace.current,
          library: 'rxdart_flutter',
        ),
      );
      return;
    }

    final buildWhen = widget._buildWhen ?? _defaultBuildWhen;

    assert(subscription == null, 'Stream already subscribed');
    subscription = stream.listen(
      (data) {
        if (buildWhen(currentData, data)) {
          setState(() => currentData = data);
        }
      },
      onError: (Object e, StackTrace s) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: e,
            stack: s,
            library: 'rxdart_flutter',
          ),
        );
      },
    );
  }

  void unsubscribe() {
    subscription?.cancel();
    subscription = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty.lazy('currentData', () => currentData));
    properties.add(DiagnosticsProperty('subscription', subscription));
  }
}
