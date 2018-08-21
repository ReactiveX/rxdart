import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('ValueObservable', () {
    test('should wrap a stream', () {
      final ValueObservable<int> observable = new SubjectValueObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      );

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('should provide sync access to the latest value', () async {
      final ValueObservable<int> observable = new SubjectValueObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      );

      expect(await observable.toList(), <int>[1, 2, 3]);
      expect(observable.value, 3);
    });

    test('can provide an initial value', () async {
      final ValueObservable<int> observable = new SubjectValueObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
        seedValue: 0,
      );

      expect(observable.value, 0);
      expect(observable, emitsInOrder(<int>[0, 1, 2, 3]));
    });

    test('can be listened to multiple times', () async {
      final ValueObservable<int> observable = new SubjectValueObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      );

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('can transform into a ValueObservable', () async {
      final ValueObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).asValueObservable();

      expect(await observable.toList(), <int>[1, 2, 3]);
      expect(observable.value, 3);
    });

    test('can transform into a ValueObservable with initial value', () async {
      final ValueObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3])
              .asValueObservable(seedValue: 0);

      expect(observable.value, 0);
      expect(observable, emitsInOrder(<int>[0, 1, 2, 3]));
    });
  });
}
