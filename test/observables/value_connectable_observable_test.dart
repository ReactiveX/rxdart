import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('BehaviorConnectableObservable', () {
    test('should not emit before connecting', () {
      final stream = MockStream<int>();
      final observable = ValueConnectableObservable(stream);

      when(stream.listen(any, onError: anyNamed('onError')))
          .thenReturn(Stream.fromIterable(const [1, 2, 3]).listen(null));

      verifyNever(stream.listen(any, onError: anyNamed('onError')));

      observable.connect();

      verify(stream.listen(any, onError: anyNamed('onError')));
    });

    test('should begin emitting items after connection', () {
      var count = 0;
      const items = [1, 2, 3];
      final observable = ValueConnectableObservable(Stream.fromIterable(items));

      observable.connect();

      expect(observable, emitsInOrder(items));
      observable.listen(expectAsync1((i) {
        expect(observable.value, items[count]);
        count++;
      }, count: items.length));
    });

    test('stops emitting after the connection is cancelled', () async {
      final observable =
          Observable.fromIterable(const [1, 2, 3]).publishValue();

      observable.connect()..cancel(); // ignore: unawaited_futures

      expect(observable, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final observable = Observable.fromIterable(const [1, 2, 3]).shareValue();

      observable.listen(null)..cancel(); // ignore: unawaited_futures

      expect(observable, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final observable = Observable.fromIterable(const [1, 2, 3]).shareValue();

      observable.listen(null);
      observable.listen(null)..cancel(); // ignore: unawaited_futures

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final observable = ValueConnectableObservable(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('replays the latest item', () async {
      final observable = ValueConnectableObservable(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(observable, emits(3));
    });

    test('replays the seeded item', () async {
      final observable =
          ValueConnectableObservable.seeded(StreamController<int>().stream, 3)
              .autoConnect();

      expect(observable, emitsInOrder(const <int>[3]));
      expect(observable, emitsInOrder(const <int>[3]));
      expect(observable, emitsInOrder(const <int>[3]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(observable, emits(3));
    });

    test('replays the seeded null item', () async {
      final observable = ValueConnectableObservable.seeded(
              StreamController<int>().stream, null)
          .autoConnect();

      expect(observable, emitsInOrder(const <int>[null]));
      expect(observable, emitsInOrder(const <int>[null]));
      expect(observable, emitsInOrder(const <int>[null]));

      await Future<Null>.delayed(Duration(milliseconds: 200));

      expect(observable, emits(null));
    });

    test('can multicast observables', () async {
      final observable = Observable.fromIterable(const [1, 2, 3]).shareValue();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('transform Observables with initial value', () async {
      final observable =
          Observable.fromIterable(const [1, 2, 3]).shareValueSeeded(0);

      expect(observable.value, 0);
      expect(observable, emitsInOrder(const <int>[0, 1, 2, 3]));
    });

    test('provides access to the latest value', () async {
      const items = [1, 2, 3];
      var count = 0;
      final observable = Observable.fromIterable(const [1, 2, 3]).shareValue();

      observable.listen(expectAsync1((data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.value, 3);
        }
      }, count: items.length));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final observable = Observable.fromIterable(const [1, 2, 3])
          .publishValue()
          .autoConnect(connection: (subscription) => subscription.cancel());

      expect(observable, neverEmits(anything));
    });
  });
}
