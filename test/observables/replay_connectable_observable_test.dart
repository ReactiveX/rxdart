import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('ReplayConnectableObservable', () {
    test('should begin emitting items after connection', () {
      final ReplayConnectableObservable<int> observable =
          ReplayConnectableObservable<int>(
              Stream<int>.fromIterable(<int>[1, 2, 3]));

      observable.connect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('stops emitting after the connection is cancelled', () async {
      final ConnectableObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).publishReplay();

      observable.connect()..cancel();

      expect(observable, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      observable.listen(null)..cancel();

      expect(observable, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      observable.listen(null);
      observable.listen(null)..cancel();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final Observable<int> observable = new ReplayConnectableObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('replays the max number of items', () async {
      final Observable<int> observable = new ReplayConnectableObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
        maxSize: 2,
      ).autoConnect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(observable, emitsInOrder(<int>[2, 3]));
    });

    test('can multicast observables', () async {
      final ReplayObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('only holds a certain number of values', () async {
      final ReplayObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      expect(observable.values, <int>[]);
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('provides access to all items', () async {
      final List<int> items = <int>[1, 2, 3];
      int count = 0;
      final ReplayObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      observable.listen(expectAsync1((int data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.values, items);
        }
      }, count: items.length));
    });

    test('provides access to a certain number of items', () async {
      final List<int> items = <int>[1, 2, 3];
      int count = 0;
      final ReplayObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareReplay(maxSize: 2);

      observable.listen(expectAsync1((int data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.values, <int>[2, 3]);
        }
      }, count: items.length));
    });
  });
}
