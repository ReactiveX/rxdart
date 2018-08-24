import 'package:rxdart/src/observables/observable.dart';

/// An [Observable] that provides synchronous access to the emitted values
abstract class ReplayObservable<T> implements Observable<T> {
  List<T> get values;
}
