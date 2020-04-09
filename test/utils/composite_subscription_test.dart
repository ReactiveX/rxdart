import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.compositeSubscription.add', () {
    final composite = CompositeSubscription();
    final s1 = Stream.fromIterable(const [1, 2, 3]).listen(null),
        s2 = Stream.fromIterable(const [4, 5, 6]).listen(null);

    expect(() {
      composite.add(s1);
      composite.add(s2);
    }, returnsNormally);
  });

  test('Rx.compositeSubscription.addNotNull', () {
    final composite = CompositeSubscription();

    expect(() => composite.add<void>(null),
        throwsA(TypeMatcher<AssertionError>()));
  });

  test('Rx.compositeSubscription.remove', () {
    final composite = CompositeSubscription();
    final s1 = Stream.fromIterable(const [1, 2, 3]).listen(null),
        s2 = Stream.fromIterable(const [4, 5, 6]).listen(null);

    composite.add(s1);
    composite.add(s2);

    expect(() {
      composite.remove(s1);
      composite.remove(s2);
    }, returnsNormally);
  });

  group('Rx.compositeSubscription.termination', () {
    test('clear', () {
      final composite = CompositeSubscription();
      final s1 = Stream.fromIterable(const [1, 2, 3]).listen(null),
          s2 = Stream.fromIterable(const [4, 5, 6]).listen(null);

      composite.add(s1);
      composite.add(s2);
      composite.clear();

      expect(composite.isDisposed, isFalse);
    });

    test('dispose', () {
      final composite = CompositeSubscription();
      final s1 = Stream.fromIterable(const [1, 2, 3]).listen(null),
          s2 = Stream.fromIterable(const [4, 5, 6]).listen(null);

      composite.add(s1);
      composite.add(s2);
      composite.dispose();

      expect(composite.isDisposed, isTrue);
    });
  });

  test('Rx.compositeSubscription.pauseAndResume', () {
    final composite = CompositeSubscription();
    final s1 = Stream.fromIterable(const [1, 2, 3]).listen(null),
        s2 = Stream.fromIterable(const [4, 5, 6]).listen(null);

    composite.add(s1);
    composite.add(s2);
    composite.pauseAll();

    expect(composite.allPaused, isTrue);
    expect(s1.isPaused, isTrue);
    expect(s2.isPaused, isTrue);

    composite.resumeAll();

    expect(composite.allPaused, isFalse);
    expect(s1.isPaused, isFalse);
    expect(s2.isPaused, isFalse);
  });

  test('Rx.compositeSubscription.allPaused', () {
    final composite = CompositeSubscription();
    final s1 = Stream.fromIterable(const [1, 2, 3]).listen(null),
        s2 = Stream.fromIterable(const [4, 5, 6]).listen(null);

    expect(composite.allPaused, isFalse);

    composite.add(s1);
    composite.add(s2);

    expect(composite.allPaused, isFalse);

    composite.pauseAll();

    expect(composite.allPaused, isTrue);

    composite.remove(s1);
    composite.remove(s2);

    /// all subscriptions are removed, allPaused should yield false
    expect(composite.allPaused, isFalse);
  });
}
