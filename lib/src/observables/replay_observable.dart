import 'package:rxdart/src/observables/observable.dart';

/// An [Observable] that provides synchronous access to the emitted values
abstract class ReplayObservable<T> implements Observable<T> {
  /// Synchronously get the values stored in Subject. May be empty.
  List<T> get values;
}
