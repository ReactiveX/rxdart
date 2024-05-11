import 'package:rxdart/src/utils/collection_extensions.dart';
import 'package:rxdart/src/utils/error_and_stacktrace.dart';

/// An [Stream] that provides synchronous access to the emitted values
abstract class ReplayStream<T> implements Stream<T> {
  /// Synchronously get the values stored in Subject. May be empty.
  List<T> get values;

  /// Synchronously get the errors and stack traces stored in Subject. May be empty.
  List<Object> get errors;

  /// Synchronously get the stack traces of errors stored in Subject. May be empty.
  List<StackTrace?> get stackTraces;
}

/// Extension method on [ReplayStream] to access the emitted [ErrorAndStackTrace]s.
extension ErrorAndStackTracesReplayStreamExtension<T> on ReplayStream<T> {
  /// Returns the emitted [ErrorAndStackTrace]s.
  /// May be empty.
  List<ErrorAndStackTrace> get errorAndStackTraces =>
      errors.zipWith<ErrorAndStackTrace, StackTrace?>(
        stackTraces,
        (e, s) => ErrorAndStackTrace(e, s),
        growable: false,
      );
}
