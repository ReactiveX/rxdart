import 'package:rxdart/src/observables/observable.dart';

/// An [Observable] that provides synchronous access to the last emitted item
abstract class ValueObservable<T> implements Observable<T> {
  /// Last emitted value, or null if there has been no emission yet
  /// See [hasValue]
  T get value;

  bool get hasValue;
}
