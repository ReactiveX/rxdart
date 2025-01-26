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
/// Similar to [StreamBuilder], but works with [ValueStream].
/// [ValueStreamBuilder] requires [stream.hasValue] to always be `true`,
/// and the [stream] does not emit any error events.
///
/// [ValueStreamBuilder] handles building a widget in response to new `data`.
/// [ValueStreamBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [ValueStream]-specific
/// performance improvements.
///
/// ### Example
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
/// ### Example
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
  ErrorAndStackTrace? error;

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
      return ErrorWidget(error!.error);
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
      error = ErrorAndStackTrace(ValueStreamHasNoValueError(stream), s);
      reportError();
      return;
    } catch (e, s) {
      error = ErrorAndStackTrace(e, s);
      reportError();
      return;
    }

    final buildWhen = widget._buildWhen;

    assert(subscription == null, 'The stream is already listened to!');
    subscription = stream.listen(
      (newData) {
        final previousData = currentData;
        currentData = newData;
        if (buildWhen == null || buildWhen(previousData, newData)) {
          setState(_emptyFn);
        }
      },
      onError: (Object e, StackTrace s) {
        error = ErrorAndStackTrace(UnhandledStreamError(e), s);
        reportError();
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
    properties.add(DiagnosticsProperty.lazy('data', () => currentData));
    properties.add(DiagnosticsProperty('error', error));
    properties.add(DiagnosticsProperty('subscription', subscription));
  }

  static void _emptyFn() {}

  void reportError() {
    final error = this.error;
    if (error == null) {
      return;
    }
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error.error,
        stack: error.stackTrace,
        library: 'rxdart_flutter',
      ),
    );
  }
}

const _bullet = ' • ';
const _indent = '   ';

/// Error emitted from [ValueStream] when using [ValueStreamBuilder].
class UnhandledStreamError extends Error {
  /// Error emitted from [ValueStream].
  final Object error;

  /// Create an [UnhandledStreamError] from [error].
  UnhandledStreamError(this.error);

  @override
  String toString() {
    return '''${_bullet}Unhandled error from the ValueStream: "$error".

${_bullet}ValueStreamBuilder requires the ValueStream never to emit any error events.
${_indent}You should use one of following methods to handle error before passing stream to ValueStreamBuilder:
$_indent  $_bullet stream.handleError((e, s) { })
$_indent  $_bullet stream.onErrorReturn(value)
$_indent  $_bullet stream.onErrorReturnWith((e) => value)
$_indent  $_bullet stream.onErrorResumeNext(otherStream)
$_indent  $_bullet stream.onErrorResume((e) => otherStream)
$_indent  $_bullet stream.transform(
$_indent  $_indent     StreamTransformer.fromHandlers(handleError: (e, s, sink) {}))
$_indent ...

${_bullet}If none of these solutions work, please file a bug at:
${_indent}https://github.com/ReactiveX/rxdart/issues/new
''';
  }
}

/// Error is thrown when [ValueStream.hasValue] is `false`.
class ValueStreamHasNoValueError<T> extends Error {
  final ValueStream<T> stream;

  ValueStreamHasNoValueError(this.stream);

  @override
  String toString() {
    return '''${_bullet}ValueStreamBuilder requires `hasValue` of "$stream" to be true.
${_indent}You can use BehaviorSubject.seeded(value), publishValueSeeded(value) or shareValueSeeded(value)
${_indent}to create a ValueStream with an initial value.

${_bullet}Otherwise, you should check `stream.hasValue` before using ValueStreamBuilder.

${_bullet}If none of these solutions work, please file a bug at:
${_indent}https://github.com/ReactiveX/rxdart/issues/new
''';
  }
}
