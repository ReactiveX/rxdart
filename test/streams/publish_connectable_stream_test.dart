import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class MockStream<T> extends Stream<T> {
  final Stream<T> stream;
  var listenCount = 0;

  MockStream(this.stream);

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    ++listenCount;
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  group('PublishConnectableStream', () {
    test('should not emit before connecting', () {
      final stream = MockStream(Stream.fromIterable(const [1, 2, 3]));
      final connectableStream = PublishConnectableStream(stream);

      expect(stream.listenCount, 0);
      connectableStream.connect();
      expect(stream.listenCount, 1);
    });

    test('should begin emitting items after connection', () {
      final ConnectableStream<int> stream = PublishConnectableStream<int>(
          Stream<int>.fromIterable(<int>[1, 2, 3]));

      stream.connect();

      expect(stream, emitsInOrder(<int>[1, 2, 3]));
    });

    test('stops emitting after the connection is cancelled', () async {
      final ConnectableStream<int> stream =
          Stream<int>.fromIterable(<int>[1, 2, 3]).publishValue();

      stream.connect()..cancel(); // ignore: unawaited_futures

      expect(stream, neverEmits(anything));
    });

    test('multicasts a single-subscription stream', () async {
      final stream = PublishConnectableStream(
        Stream.fromIterable(const [1, 2, 3]),
      ).autoConnect();

      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));
    });

    test('can multicast streams', () async {
      final stream = Stream.fromIterable(const [1, 2, 3]).publish();

      stream.connect();

      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));
      expect(stream, emitsInOrder(<int>[1, 2, 3]));
    });

    test('refcount automatically connects', () async {
      final stream = Stream.fromIterable(const [1, 2, 3]).share();

      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
      expect(stream, emitsInOrder(const <int>[1, 2, 3]));
    });

    test('provide a function to autoconnect that stops listening', () async {
      final stream = Stream.fromIterable(const [1, 2, 3])
          .publish()
          .autoConnect(connection: (subscription) => subscription.cancel());

      expect(await stream.isEmpty, true);
    });
  });
}
