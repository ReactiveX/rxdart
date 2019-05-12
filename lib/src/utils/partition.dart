import 'package:rxdart/src/observables/observable.dart';

class ParititonUtil {
  /// Splits the [source] Observable into two, one with values that satisfy a
  /// [predicate], and another with values that don't satisfy the [predicate].
  static List<Observable<T>> parititon<T>(
    Observable<T> source,
    bool predicate(T event),
  ) {
    bool Function(T) not(bool test(T event)) => (event) => !test(event);
    if (source.isBroadcast) {
      return <Observable<T>>[
        source.where(predicate),
        source.where(not(predicate)),
      ];
    } else {
      final shared = source.share();
      return <Observable<T>>[
        shared.where(predicate),
        shared.where(not(predicate)),
      ];
    }
  }
}
