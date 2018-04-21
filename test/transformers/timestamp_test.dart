import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.Observable.timestamp', () async {
    final List<int> expected = <int>[1, 2, 3];
    int count = 0;

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3]))
        .timestamp()
        .listen(expectAsync1((Timestamped<int> result) {
          expect(result.value, expected[count++]);
        }, count: expected.length));
  });

  test('Rx.Observable.timestamp.reusable', () async {
    final TimestampStreamTransformer<int> transformer =
        new TimestampStreamTransformer<int>();
    final List<int> expected = <int>[1, 2, 3];
    int countA = 0, countB = 0;

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3]))
        .transform(transformer)
        .listen(expectAsync1((Timestamped<int> result) {
          expect(result.value, expected[countA++]);
        }, count: expected.length));

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3]))
        .transform(transformer)
        .listen(expectAsync1((Timestamped<int> result) {
          expect(result.value, expected[countB++]);
        }, count: expected.length));
  });

  test('timestampTransformer', () async {
    final List<int> expected = <int>[1, 2, 3];
    int count = 0;

    new Stream<int>.fromIterable(<int>[1, 2, 3])
        .transform(new TimestampStreamTransformer<int>())
        .listen(expectAsync1((Timestamped<int> result) {
          expect(result.value, expected[count++]);
        }, count: expected.length));
  });

  test('timestampTransformer.asBroadcastStream', () async {
    Stream<Timestamped<int>> stream =
        new Stream<int>.fromIterable(<int>[1, 2, 3])
            .transform(new TimestampStreamTransformer<int>())
            .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('timestampTransformer.error.shouldThrow', () async {
    Stream<Timestamped<int>> streamWithError =
        new ErrorStream<int>(new Exception())
            .transform(new TimestampStreamTransformer<int>());

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('timestampTransformer.pause.resume', () async {
    final Stream<Timestamped<int>> stream =
        new Stream<int>.fromIterable(<int>[1, 2, 3])
            .transform(new TimestampStreamTransformer<int>());
    final List<int> expected = <int>[1, 2, 3];
    StreamSubscription<Timestamped<int>> subscription;
    int count = 0;

    subscription = stream.listen(expectAsync1((Timestamped<int> result) {
      expect(result.value, expected[count++]);

      if (count == expected.length) {
        subscription.cancel();
      }
    }, count: expected.length));

    subscription.pause();
    subscription.resume();
  });
}
