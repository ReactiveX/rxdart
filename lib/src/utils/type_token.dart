/// A class that captures the Type to filter down to using `ofType` or `cast`.
///
/// Given the way Dart generics work, one cannot simply use the `is T` / `as T`
/// checks and castings within an ofTypeObservable itself. Therefore, this class
/// was introduced to capture the type of class you'd like `ofType` to filter
/// down to, or `cast` to cast to.
///
/// ### Example
///
///     new Stream.fromIterable([1, "hi"])
///       .ofType(new TypeToken<String>)
///       .listen(print); // prints "hi"
class TypeToken<S> {
  const TypeToken();

  bool isType(dynamic other) {
    return other is S;
  }

  S toType(dynamic other) {
    // ignore: avoid_as
    return other as S;
  }
}

/// Filter the observable to only Booleans
const TypeToken<bool> kBool = const TypeToken<bool>();

/// Filter the observable to only Doubles
const TypeToken<double> kDouble = const TypeToken<double>();

/// Filter the observable to only Integers
const TypeToken<int> kInt = const TypeToken<int>();

/// Filter the observable to only Numbers
const TypeToken<num> kNum = const TypeToken<num>();

/// Filter the observable to only Strings
const TypeToken<String> kString = const TypeToken<String>();

/// Filter the observable to only Symbols
const TypeToken<Symbol> kSymbol = const TypeToken<Symbol>();
