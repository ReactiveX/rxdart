import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'errors.dart';
import 'value_stream_builder.dart';
import 'value_stream_listener.dart';

/// {@template value_stream_consumer}
/// [ValueStreamConsumer] exposes a [builder] and [listener] to react to new
/// values from a [stream].
///
/// [ValueStreamConsumer] is analogous to a nested [ValueStreamListener] and
/// [ValueStreamBuilder] but reduces the amount of boilerplate needed.
///
/// [ValueStreamConsumer] requires [stream.hasValue] to always be `true`,
/// and the [stream] does not emit any error events.
/// See [ValueStreamHasNoValueError] and [UnhandledStreamError]
/// for more information.
///
/// [ValueStreamConsumer] should only be used when it is necessary to both
/// rebuild UI and execute other reactions to value changes in the [stream].
///
/// [ValueStreamConsumer] takes a required  `ValueStream`,
/// `ValueStreamWidgetListener` and  `ValueStreamWidgetBuilder`
/// and an optional `ValueStreamBuilderCondition`.
///
/// **Example**
///
/// ```dart
/// ValueStreamConsumer<T>(
///   stream: valueStream,
///   listener: (context, previous, current) {
///     // do stuff here based on valueStream's
///     // previous and current values
///   },
///   builder: (context, value, child) {
///     // Build widget based on valueStream's value
///   },
///   child: const SizedBox(), // Optional child widget that remains stable
/// )
/// ```
///
/// An optional [buildWhen]  can be implemented for more
/// granular control over when [builder] is called.
/// The [buildWhen] will be invoked on each [stream] `value`
/// change.
/// It takes the previous `value` and current `value` and must return
/// a [bool] which determines whether or not the [builder]
/// function will be invoked.
/// The previous `value` will be initialized to the `value` of the [stream] when
/// the [ValueStreamConsumer] is initialized.
/// [buildWhen] is optional and if it isn't implemented,
/// it will default to `true`.
///
/// [child] is optional but is good practice to use if part of
/// the widget subtree does not depend on the value of the [stream].
///
/// **Example**
///
/// ```dart
/// ValueStreamConsumer<T>(
///   stream: valueStream,
///   listener: (context, previous, current) {
///     // do stuff here based on valueStream's
///     // previous and current values
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with valueStream's value
///   },
///   builder: (context, value, child) {
///     // Build widget based on valueStream's value
///   },
///   child: const SizedBox(), // Optional child widget that remains stable
/// )
/// ```
/// {@endtemplate}
class ValueStreamConsumer<T> extends StatefulWidget {
  /// {@macro value_stream_consumer}
  const ValueStreamConsumer({
    Key? key,
    required this.stream,
    required this.listener,
    required this.builder,
    this.buildWhen,
    this.child,
    this.isReplayValueStream = true,
  }) : super(key: key);

  /// The [ValueStream] that the [ValueStreamConsumer] will interact with.
  final ValueStream<T> stream;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `value` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final ValueStreamWidgetBuilder<T> builder;

  /// Takes the `BuildContext` along with the `previous` and `current` values
  ///  and is responsible for executing in response to `value` changes.
  final ValueStreamWidgetListener<T> listener;

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
  ///
  /// Defaults to `true`.
  final bool isReplayValueStream;

  @override
  State<ValueStreamConsumer<T>> createState() => _ValueStreamConsumerState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ValueStream<T>>('stream', stream))
      ..add(
          DiagnosticsProperty<bool>('isReplayValueStream', isReplayValueStream))
      ..add(ObjectFlagProperty<ValueStreamWidgetBuilder<T>>.has(
        'builder',
        builder,
      ))
      ..add(ObjectFlagProperty<ValueStreamBuilderCondition<T>?>.has(
        'buildWhen',
        buildWhen,
      ))
      ..add(ObjectFlagProperty<ValueStreamWidgetListener<T>>.has(
        'listener',
        listener,
      ))
      ..add(ObjectFlagProperty<Widget?>.has('child', child));
  }
}

class _ValueStreamConsumerState<T> extends State<ValueStreamConsumer<T>> {
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
        widget.listener(context, previous, current);

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
