import 'dart:async';

/// Extends the Stream class with the ability to skip items that have previously
/// been emitted.
extension DistinctByExtension<T> on Stream<T> {
  /// Creates a Stream where data events are skipped if they have already
  /// been emitted before.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#distinct)
  Stream<T> distinctBy<S>(
    S Function(T it) distincter,
  ) =>
      distinct((prev, next) => distincter(prev) == distincter(next));
}
