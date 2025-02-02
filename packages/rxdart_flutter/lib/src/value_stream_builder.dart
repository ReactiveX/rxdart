import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'errors.dart';
import 'value_stream_listener.dart';

/// Signature for the `builder` function which takes the `BuildContext` and the current `value`
/// and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef ValueStreamWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T value,
  Widget? child,
);

/// Signature for the `buildWhen` function which takes the previous and
/// current `value` and is responsible for returning a [bool] which
/// determines whether to rebuild [ValueStreamBuilder] with the current `value`.
typedef ValueStreamBuilderCondition<S> = bool Function(S previous, S current);

/// {@template value_stream_builder}
/// [ValueStreamBuilder] handles building a widget in response to new `value`.
/// [ValueStreamBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [ValueStream]-specific
/// performance improvements.
///
/// [ValueStreamBuilder] requires [stream.hasValue] to always be `true`,
/// and the [stream] does not emit any error events.
/// See [ValueStreamHasNoValueError] and [UnhandledStreamError]
/// for more information.
///
/// Please refer to [ValueStreamListener] if you want to "do" anything in response to
/// `value` changes such as navigation, showing a dialog, etc...
///
/// [ValueStreamBuilder] handles building a widget in response to new `value`.
/// [ValueStreamBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [ValueStream]-specific
/// performance improvements.
///
/// **Example**
///
/// ```dart
/// ValueStreamBuilder<T>(
///   stream: valueStream,
///   builder: (context, value, child) {
///     // return widget here based on valueStream's value
///   },
///   child: const SizedBox(), // Optional child widget that remains stable
/// );
/// ```
/// {@endtemplate}
///
/// {@template value_stream_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [ValueStreamBuilder] rebuilds.
///
/// - [buildWhen] should only be used for performance optimizations as it
/// provides no security about the value passed to the [builder] function.
/// - [buildWhen] will be invoked on each [stream] `value` change.
/// - [buildWhen] takes the previous `value` and current `value` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// - The previous `value` will be initialized to the `value` of the [stream] when
/// the [ValueStreamBuilder] is initialized.
///
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// [child] is optional but is good practice to use if part of
/// the widget subtree does not depend on the value of the [stream].
///
/// **Example**
///
/// ```dart
/// ValueStreamBuilder<T>(
///   stream: valueStream,
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with valueStream's value
///   },
///   builder: (context, value, child) {
///     // return widget here based on valueStream's value
///   },
///   child: const SizedBox(), // Optional child widget that remains stable
/// )
/// ```
/// {@endtemplate}
class ValueStreamBuilder<T> extends StatefulWidget {
  /// {@macro value_stream_builder}
  /// {@macro value_stream_builder_build_when}
  const ValueStreamBuilder({
    Key? key,
    required this.stream,
    required this.builder,
    this.buildWhen,
    this.child,
    this.isReplayValueStream,
  }) : super(key: key);

  /// The [ValueStream] that the [ValueStreamBuilder] will interact with.
  final ValueStream<T> stream;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `value` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final ValueStreamWidgetBuilder<T> builder;

  /// Takes the previous `value` and the current `value` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `value`.
  final ValueStreamBuilderCondition<T>? buildWhen;

  /// A [ValueStream]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree the
  /// [builder] builds depends on the value of the [stream]. For
  /// example, in the case where the [stream] is a [String] and the
  /// [builder] returns a [Text] widget with the current [String] value, there
  /// would be no useful [child].
  final Widget? child;

  /// Whether or not the [stream] emits the last value
  /// like [BehaviorSubject] does.
  /// See [ValueStream.isReplayValueStream] for more information.
  ///
  /// If this argument is `null`, the [ValueStream.isReplayValueStream] is used instead.
  ///
  /// Defaults to `null`.
  final bool? isReplayValueStream;

  @override
  State<ValueStreamBuilder<T>> createState() => _ValueStreamBuilderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueStream<T>>('stream', stream))
      ..add(
          DiagnosticsProperty<bool>('isReplayValueStream', isReplayValueStream))
      ..add(ObjectFlagProperty<ValueStreamBuilderCondition<T>?>.has(
        'buildWhen',
        buildWhen,
      ))
      ..add(ObjectFlagProperty<ValueStreamWidgetBuilder<T>>.has(
        'builder',
        builder,
      ))
      ..add(ObjectFlagProperty<Widget?>.has('child', child));
  }
}

class _ValueStreamBuilderState<T> extends State<ValueStreamBuilder<T>> {
  late T _currentValue;
  ErrorAndStackTrace? _error;

  @override
  void initState() {
    super.initState();
    _error = validateValueStreamInitialValue(widget.stream);
    if (_error != null) {
      return;
    }
    _currentValue = widget.stream.value;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorWidget(_error!.error);
    }
    return ValueStreamListener<T>(
      stream: widget.stream,
      isReplayValueStream: widget.isReplayValueStream,
      listener: (context, previous, current) {
        if (widget.buildWhen?.call(previous, current) ?? true) {
          setState(() {
            _currentValue = current;
          });
        }
      },
      child: widget.builder(context, _currentValue, widget.child),
    );
  }
}
