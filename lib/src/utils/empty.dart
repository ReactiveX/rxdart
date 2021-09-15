class _Empty {
  const _Empty();

  @override
  String toString() => '<<EMPTY>>';
}

/// TODO
const Object? EMPTY = _Empty(); // ignore: constant_identifier_names

/// TODO
T? unbox<T>(Object? o) => identical(o, EMPTY) ? null : o as T;

/// TODO
bool isNotEmpty(Object? o) => !identical(o, EMPTY);
