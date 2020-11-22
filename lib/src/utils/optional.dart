/// Wrap a value
class Optional<T> {
  /// Wrapped value
  final T value;

  /// Construct an [Optional] from a value.
  Optional(this.value);

  @override
  String toString() => 'Optional{value: $value}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Optional &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
