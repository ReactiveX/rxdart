import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('CompositeSubscription', () {
    test('should cancel all subscriptions on clear()', () {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareValue();
      final CompositeSubscription composite = CompositeSubscription();

      composite.add(observable.listen(null))
        ..add(observable.listen(null))
        ..add(observable.listen(null));

      composite.clear();

      expect(observable, neverEmits(anything));
    });
    test('should cancel all subscriptions on dispose()', () {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareValue();
      final CompositeSubscription composite = CompositeSubscription();

      composite.add(observable.listen(null))
        ..add(observable.listen(null))
        ..add(observable.listen(null));

      composite.dispose();

      expect(observable, neverEmits(anything));
    });
    test('should throw exception if trying to add subscription to disposed composite', () {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareValue();
      final CompositeSubscription composite = CompositeSubscription();

      composite.dispose();

      expect(() => composite.add(observable.listen(null)), throwsA(anything));
    });
    test('should not cancel subscription on clear if it is removed from composite', () {
      const int value = 1;
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[value]).shareValue();
      final CompositeSubscription composite = CompositeSubscription();

      final Func1<Null, int> listener = expectAsync1((int a) {
        expect(a, value);
      }, count: 1);
      final StreamSubscription<int> subscription = observable.listen(listener);

      composite.add(subscription)..remove(subscription);

      composite.clear();
    });
    test('should not cancel subscription on dispose if it is removed from composite', () {
      const int value = 1;
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[value]).shareValue();
      final CompositeSubscription composite = CompositeSubscription();

      final Func1<Null, int> listener = expectAsync1((int a) {
        expect(a, value);
      }, count: 1);
      final StreamSubscription<int> subscription = observable.listen(listener);

      composite.add(subscription)..remove(subscription);

      composite.dispose();
    });
  });
}
