import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('BehaviorConnectableObservable', () {
    test('should not emit before connecting', () {
      final Stream<int> stream = MockStream<int>();
      final BehaviorConnectableObservable<int> observable =
          BehaviorConnectableObservable<int>(stream);

      when(stream.listen(any, onError: anyNamed('onError'))).thenReturn(
          new Stream<int>.fromIterable(<int>[1, 2, 3]).listen(null));

      verifyNever(stream.listen(any, onError: anyNamed('onError')));

      observable.connect();

      verify(stream.listen(any, onError: anyNamed('onError')));
    });

    test('should begin emitting items after connection', () {
      int count = 0;
      final List<int> items = <int>[1, 2, 3];
      final BehaviorConnectableObservable<int> observable =
          BehaviorConnectableObservable<int>(Stream<int>.fromIterable(items));

      observable.connect();

      expect(observable, emitsInOrder(items));
      observable.listen(expectAsync1((int i) {
        expect(observable.value, items[count]);
        count++;
      }, count: items.length));
    });

    test('stops emitting after the connection is cancelled', () async {
      final ConnectableObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).publishBehavior();

      observable.connect()..cancel();

      expect(observable, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareBehavior();

      observable.listen(null)..cancel();

      expect(observable, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareBehavior();

      observable.listen(null);
      observable.listen(null)..cancel();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final Observable<int> observable = new BehaviorConnectableObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('replays the latest item', () async {
      final Observable<int> observable = new BehaviorConnectableObservable<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(observable, emits(3));
    });

    test('can multicast observables', () async {
      final BehaviorObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareBehavior();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('transform Observables with initial value', () async {
      final BehaviorObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3])
              .shareBehavior(seedValue: 0);

      expect(observable.value, 0);
      expect(observable, emitsInOrder(<int>[0, 1, 2, 3]));
    });

    test('provides access to the latest value', () async {
      final List<int> items = <int>[1, 2, 3];
      int count = 0;
      final BehaviorObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).shareBehavior();

      observable.listen(expectAsync1((int data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.value, 3);
        }
      }, count: items.length));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3])
              .publishBehavior()
              .autoConnect(
                  connection: (StreamSubscription<int> subscription) =>
                      subscription.cancel());

      expect(observable, neverEmits(anything));
    });
  });
}
