/// An [Stream] that provides synchronous access to the emitted values
abstract class ReplayStream<T> implements Stream<T> {
  /// Synchronously get the values stored in Subject. May be empty.
  List<T> get values;

  /// Synchronously get the errors stored in Subject. May be empty.
  List<Object> get errors;
}
