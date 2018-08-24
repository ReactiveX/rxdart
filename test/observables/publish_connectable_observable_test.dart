import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('PublishConnectableObservable', () {
    test('should begin emitting items after connection', () {
      final ConnectableObservable<int> observable =
          PublishConnectableObservable<int>(
              Stream<int>.fromIterable(<int>[1, 2, 3]));

      observable.connect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('stops emitting after the connection is cancelled', () async {
      final ConnectableObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).publishBehavior();

      observable.connect()..cancel();

      expect(observable, neverEmits(anything));
    });

    test('multicasts a single-subscription stream', () async {
      final Observable<int> observable = new PublishConnectableObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('can multicast observables', () async {
      final ConnectableObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).publish();

      observable.connect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });
  });
}
