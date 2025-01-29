import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

const _bullet = ' • ';
const _indent = '   ';

/// Error emitted from [ValueStream] when using [ValueStreamBuilder],
/// [ValueStreamListener], or [ValueStreamConsumer].
class UnhandledStreamError extends Error {
  /// Error emitted from [ValueStream].
  final Object error;

  /// Create an [UnhandledStreamError] from [error].
  UnhandledStreamError(this.error);

  @override
  String toString() {
    return '''${_bullet}Unhandled error emitted from the ValueStream: "$error".

${_bullet}The ValueStreamBuilder, ValueStreamListener, or ValueStreamConsumer requires the ValueStream to never emit any error events.

${_bullet}If you are using a BehaviorSubject, ensure you only call subject.add(data),
${_indent}and never call subject.addError(error).

${_indent}To handle errors before passing the stream to ValueStreamBuilder, ValueStreamListener, or ValueStreamConsumer, you can use one of the following methods:
$_indent  $_bullet stream.handleError((error, stackTrace) { })
$_indent  $_bullet stream.onErrorReturn(value)
$_indent  $_bullet stream.onErrorReturnWith((error, stackTrace) => value)
$_indent  $_bullet stream.onErrorResumeNext(otherStream)
$_indent  $_bullet stream.onErrorResume((error, stackTrace) => otherStream)
$_indent  $_bullet stream.transform(
$_indent  $_indent     StreamTransformer.fromHandlers(handleError: (error, stackTrace, sink) {}))
$_indent  ...

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
${_indent}This means the ValueStream must always have the value.

${_indent}If you are using a BehaviorSubject, use `BehaviorSubject.seeded(value)`
or call `subject.add(value)` to provide an initial value before using ValueStreamBuilder.

${_indent}Alternatively, you can create a ValueStream with an initial value using:
$_indent  $_bullet stream.publishValueSeeded(value)
$_indent  $_bullet stream.shareValueSeeded(value)
$_indent  ...

${_bullet}Lastly, you can check if the ValueStream has a value before using ValueStreamBuilder, ValueStreamListener, or ValueStreamConsumer, for example:
$_indent if (valueStream.hasValue) {
$_indent   return ValueStreamBuilder(...);
$_indent } else {
$_indent   return FallBackWidget();
$_indent }

${_bullet}If none of these solutions work, please file a bug at:
${_indent}https://github.com/ReactiveX/rxdart/issues/new
''';
  }
}

void reportError(ErrorAndStackTrace error) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error.error,
      stack: error.stackTrace,
      library: 'rxdart_flutter',
    ),
  );
}

// @pragma('vm:notify-debugger-on-exception')
ErrorAndStackTrace? validateValueStreamInitialValue<T>(ValueStream<T> stream) {
  ErrorAndStackTrace? error;

  if (!stream.hasValue) {
    if (stream.hasError) {
      error = ErrorAndStackTrace(
        UnhandledStreamError(stream.error),
        stream.stackTrace ?? StackTrace.current,
      );
    } else {
      error = ErrorAndStackTrace(
        ValueStreamHasNoValueError(stream),
        stream.stackTrace ?? StackTrace.current,
      );
    }
  }

  if (error != null) {
    reportError(error);
  }

  return error;
}
