import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('CompositeSubscription', () {
    test('should cancel all subscriptions on clear()', () {
      final stream = Stream.fromIterable(const [1, 2, 3]).shareValue();
      final composite = CompositeSubscription();

      composite
        ..add(stream.listen(null))
        ..add(stream.listen(null))
        ..add(stream.listen(null));

      composite.clear();

      expect(stream, neverEmits(anything));
    });
    test('should cancel all subscriptions on dispose()', () {
      final stream = Stream.fromIterable(const [1, 2, 3]).shareValue();
      final composite = CompositeSubscription();

      composite
        ..add(stream.listen(null))
        ..add(stream.listen(null))
        ..add(stream.listen(null));

      composite.dispose();

      expect(stream, neverEmits(anything));
    });
    test(
        'should throw exception if trying to add subscription to disposed composite',
        () {
      final stream = Stream.fromIterable(const [1, 2, 3]).shareValue();
      final composite = CompositeSubscription();

      composite.dispose();

      expect(() => composite.add(stream.listen(null)), throwsA(anything));
    });
    test('should cancel subscription on if it is removed from composite', () {
      const value = 1;
      final stream = Stream.fromIterable([value]).shareValue();
      final composite = CompositeSubscription();
      final subscription = stream.listen(null);

      composite.add(subscription);
      composite.remove(subscription);

      expect(stream, neverEmits(anything));
    });
  });
}
