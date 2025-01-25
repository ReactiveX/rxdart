import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

/// Signature for the `builder` function which takes the `BuildContext` and the current `data`
/// and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef ValueStreamWidgetBuilder<T> = Widget Function(
    BuildContext context, T data);

/// Signature for the `buildWhen` function which takes the previous `data` and
/// the current `data` and is responsible for returning a [bool] which
/// determines whether to rebuild [ValueStream] with the current `data`.
typedef ValueStreamBuilderCondition<S> = bool Function(S previous, S current);

/// {@template value_stream_builder}
/// Similar to [StreamBuilder], but works with [ValueStream],
/// and with only-data events, not error events.
///
/// [ValueStreamBuilder] handles building a widget in response to new `data`.
/// [ValueStreamBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [ValueStream]-specific
/// performance improvements.
///
/// ```dart
/// final valueStream = BehaviorSubject<int>.seeded(0);
///
/// ValueStreamBuilder<int>(
///   stream: valueStream,
///   builder: (context, data) {
///     // return widget here based on data
///   },
/// );
/// ```
/// {@endtemplate}
///
/// {@template value_stream_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [ValueStreamBuilder] rebuilds.
///
/// - [buildWhen] should only be used for performance optimizations as it
/// provides no security about the data passed to the [builder] function.
/// - [buildWhen] will be invoked on each [ValueStream] `data` change.
/// - [buildWhen] takes the previous `data` and current `data` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// - The previous `data` will be initialized to the `data` of the [ValueStream] when
/// the [ValueStreamBuilder] is initialized.
///
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// ValueStreamBuilder<Data>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with data
///   },
///   builder: (context, data) {
///     // return widget here based on data
///   }
/// )
/// ```
/// {@endtemplate}
class ValueStreamBuilder<T> extends StatefulWidget {
  final ValueStreamWidgetBuilder<T> _builder;
  final ValueStream<T> _stream;
  final ValueStreamBuilderCondition<T>? _buildWhen;

  /// {@macro value_stream_builder}
  /// {@macro value_stream_builder_build_when}
  const ValueStreamBuilder({
    Key? key,
    required ValueStream<T> stream,
    required ValueStreamWidgetBuilder<T> builder,
    ValueStreamBuilderCondition<T>? buildWhen,
  })  : _builder = builder,
        _stream = stream,
        _buildWhen = buildWhen,
        super(key: key);

  @override
  State<ValueStreamBuilder<T>> createState() => _ValueStreamBuilderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueStream<T>>('stream', _stream))
      ..add(ObjectFlagProperty<ValueStreamWidgetBuilder<T>>.has(
          'builder', _builder))
      ..add(
        ObjectFlagProperty<ValueStreamBuilderCondition<T>?>.has(
          'buildWhen',
          _buildWhen,
        ),
      );
  }
}

class _ValueStreamBuilderState<T> extends State<ValueStreamBuilder<T>> {
  late T currentData;
  StreamSubscription<T>? subscription;
  Object? error;

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void didUpdateWidget(covariant ValueStreamBuilder<T> oldWidget) {
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
  Widget build(BuildContext context) {
    if (error != null) {
      throw error!;
    }
    return widget._builder(context, currentData);
  }

  @pragma('vm:notify-debugger-on-exception')
  void subscribe() {
    final stream = widget._stream;

    try {
      currentData = stream.value;
      error = null;
    } on ValueStreamError catch (e, s) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error = ValueStreamHasNoValueError(stream),
          stack: s,
          library: 'rxdart_flutter',
        ),
      );
      return;
    } catch (e, s) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error = e,
          stack: s,
          library: 'rxdart_flutter',
        ),
      );
      return;
    }

    final buildWhen = widget._buildWhen;

    assert(subscription == null, 'Stream already subscribed');
    subscription = stream.listen(
      (data) {
        if (buildWhen?.call(currentData, data) ?? true) {
          currentData = data;
          setState(_emptyFn);
        }
      },
      onError: (Object e, StackTrace s) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error = UnhandledStreamError(e),
            stack: s,
            library: 'rxdart_flutter',
          ),
        );
        setState(_emptyFn);
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

  static void _emptyFn() {}
}

/// Error emitted from [Stream] when using [ValueStreamBuilder].
class UnhandledStreamError extends Error {
  /// Error emitted from [Stream].
  final Object error;

  /// Create an [UnhandledStreamError] from [error].
  UnhandledStreamError(this.error);

  @override
  String toString() {
    return '''Unhandled error from ValueStream: $error.
ValueStreamBuilder requires ValueStream never to emit error events.
You should use one of following methods to handle error before passing stream to ValueStreamBuilder:
  * stream.handleError((e, s) { })
  * stream.onErrorReturn(value)
  * stream.onErrorReturnWith((e) => value)
  * stream.onErrorResumeNext(otherStream)
  * stream.onErrorResume((e) => otherStream)
  * stream.transform(
        StreamTransformer.fromHandlers(handleError: (e, s, sink) {}))
  ...
If none of these solutions work, please file a bug at:
https://github.com/ReactiveX/rxdart/issues/new
''';
  }
}

/// Error is thrown when [ValueStream.hasValue] is `false`.
class ValueStreamHasNoValueError<T> extends Error {
  final ValueStream<T> stream;

  ValueStreamHasNoValueError(this.stream);

  @override
  String toString() {
    return '''ValueStreamBuilder requires hasValue of $stream to be `true`.
You can use BehaviorSubject.seeded(value), or publishValueSeeded(value)/shareValueSeeded(value) to create a ValueStream with an initial value.
Otherwise, you should check stream.hasValue before using ValueStreamBuilder.
If none of these solutions work, please file a bug at:
https://github.com/ReactiveX/rxdart/issues/new
    ''';
  }
}
