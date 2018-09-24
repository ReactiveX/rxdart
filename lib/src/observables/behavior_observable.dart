import 'package:rxdart/src/observables/observable.dart';

/// An [Observable] that provides synchronous access to the last emitted item
abstract class BehaviorObservable<T> implements Observable<T> {
  T get value;
}
