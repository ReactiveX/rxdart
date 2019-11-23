import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('ReplayConnectableStream', () {
    test('should not emit before connecting', () {
      final stream = MockStream<int>();
      final observable = ReplayConnectableStream(stream);

      when(stream.listen(any, onError: anyNamed('onError')))
          .thenReturn(Stream.fromIterable(const [1, 2, 3]).listen(null));

      verifyNever(stream.listen(any, onError: anyNamed('onError')));

      observable.connect();

      verify(stream.listen(any, onError: anyNamed('onError')));
    });

    test('should begin emitting items after connection', () {
      const items = [1, 2, 3];
      final observable = ReplayConnectableStream(Stream.fromIterable(items));

      observable.connect();

      expect(observable, emitsInOrder(items));
      observable.listen(expectAsync1((int i) {
        expect(observable.values, items.sublist(0, i));
      }, count: items.length));
    });

    test('stops emitting after the connection is cancelled', () async {
      final ConnectableStream<int> observable =
          Stream<int>.fromIterable(<int>[1, 2, 3]).publishReplay();

      observable.connect()..cancel(); // ignore: unawaited_futures

      expect(observable, neverEmits(anything));
    });

    test('stops emitting after the last subscriber unsubscribes', () async {
      final Stream<int> observable =
          Stream<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      observable.listen(null)..cancel(); // ignore: unawaited_futures

      expect(observable, neverEmits(anything));
    });

    test('keeps emitting with an active subscription', () async {
      final Stream<int> observable =
          Stream<int>.fromIterable(<int>[1, 2, 3]).shareReplay();

      observable.listen(null);
      observable.listen(null)..cancel(); // ignore: unawaited_futures

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('multicasts a single-subscription stream', () async {
      final Stream<int> observable = ReplayConnectableStream<int>(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
      ).autoConnect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('replays the max number of items', () async {
      final Stream<int> observable = ReplayConnectableStream<int>(
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
      final observable = Stream.fromIterable(const [1, 2, 3]).shareReplay();

      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('only holds a certain number of values', () async {
      final observable = Stream.fromIterable(const [1, 2, 3]).shareReplay();

      expect(observable.values, const <int>[]);
      expect(observable, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('provides access to all items', () async {
      const items = [1, 2, 3];
      var count = 0;
      final observable = Stream.fromIterable(const [1, 2, 3]).shareReplay();

      observable.listen(expectAsync1((int data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.values, items);
        }
      }, count: items.length));
    });

    test('provides access to a certain number of items', () async {
      const items = [1, 2, 3];
      var count = 0;
      final observable =
          Stream.fromIterable(const [1, 2, 3]).shareReplay(maxSize: 2);

      observable.listen(expectAsync1((data) {
        expect(data, items[count]);
        count++;
        if (count == items.length) {
          expect(observable.values, const <int>[2, 3]);
        }
      }, count: items.length));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final observable = Stream.fromIterable(const [1, 2, 3])
          .publishReplay()
          .autoConnect(connection: (subscription) => subscription.cancel());

      expect(observable, neverEmits(anything));
    });
  });
}
