/// Wrap a value.
/// This used to keep the latest value of a [Stream] including `null` value.
class ValueWrapper<T> {
  /// Wrapped value.
  final T value;

  /// Construct a [ValueWrapper] from [value].
  ValueWrapper(this.value);

  @override
  String toString() => 'ValueWrapper{value: $value}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueWrapper &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
