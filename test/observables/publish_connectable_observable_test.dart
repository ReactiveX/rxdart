import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('PublishConnectableObservable', () {
    test('should not emit before connecting', () {
      final Stream<int> stream = MockStream<int>();
      final PublishConnectableObservable<int> observable =
          PublishConnectableObservable<int>(stream);

      when(stream.listen(any, onError: anyNamed('onError'))).thenReturn(
          new Stream<int>.fromIterable(<int>[1, 2, 3]).listen(null));

      verifyNever(stream.listen(any, onError: anyNamed('onError')));

      observable.connect();

      verify(stream.listen(any, onError: anyNamed('onError')));
    });

    test('should begin emitting items after connection', () {
      final ConnectableObservable<int> observable =
          PublishConnectableObservable<int>(
              Stream<int>.fromIterable(<int>[1, 2, 3]));

      observable.connect();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('stops emitting after the connection is cancelled', () async {
      final ConnectableObservable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).publishValue();

      observable.connect()..cancel(); // ignore: unawaited_futures

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

    test('refcount automatically connects', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).share();

      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
      expect(observable, emitsInOrder(<int>[1, 2, 3]));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final Observable<int> observable =
          Observable<int>.fromIterable(<int>[1, 2, 3]).publish().autoConnect(
              connection: (StreamSubscription<int> subscription) =>
                  subscription.cancel());

      expect(observable, neverEmits(anything));
    });
  });
}
