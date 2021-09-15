class _Empty {
  const _Empty();

  @override
  String toString() => '<<EMPTY>>';
}

/// TODO
// ignore: constant_identifier_names
const Object? EMPTY = _Empty();

/// TODO
T? unbox<T>(Object? o) => identical(o, EMPTY) ? null : o as T;

/// TODO
bool isNotEmpty(Object? o) => !identical(o, EMPTY);
