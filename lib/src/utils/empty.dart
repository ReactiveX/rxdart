class _Empty {
  const _Empty();

  @override
  String toString() => '<<EMPTY>>';
}

/// Sentinel object.
const Object? EMPTY = _Empty(); // ignore: constant_identifier_names

/// Returns `null` if [o] is [EMPTY], otherwise returns [o] itself.
T? unbox<T>(Object? o) => identical(o, EMPTY) ? null : o as T;

/// Check [o] is [EMPTY].
bool isNotEmpty(Object? o) => !identical(o, EMPTY);
