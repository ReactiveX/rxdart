import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('CompositeSubscription', () {
    test('should cancel all subscriptions on clear()', () {
      final observable = Stream.fromIterable(const [1, 2, 3]).shareValue();
      final composite = CompositeSubscription();

      composite
        ..add(observable.listen(null))
        ..add(observable.listen(null))
        ..add(observable.listen(null));

      composite.clear();

      expect(observable, neverEmits(anything));
    });
    test('should cancel all subscriptions on dispose()', () {
      final observable = Stream.fromIterable(const [1, 2, 3]).shareValue();
      final composite = CompositeSubscription();

      composite
        ..add(observable.listen(null))
        ..add(observable.listen(null))
        ..add(observable.listen(null));

      composite.dispose();

      expect(observable, neverEmits(anything));
    });
    test(
        'should throw exception if trying to add subscription to disposed composite',
        () {
      final observable = Stream.fromIterable(const [1, 2, 3]).shareValue();
      final composite = CompositeSubscription();

      composite.dispose();

      expect(() => composite.add(observable.listen(null)), throwsA(anything));
    });
    test('should cancel subscription on if it is removed from composite', () {
      const value = 1;
      final observable = Stream.fromIterable([value]).shareValue();
      final composite = CompositeSubscription();
      final subscription = observable.listen(null);

      composite.add(subscription);
      composite.remove(subscription);

      expect(observable, neverEmits(anything));
    });
  });
}
