import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.Observable.timestamp', () async {
    const expected = [1, 2, 3];
    var count = 0;

    new Observable(new Stream.fromIterable(const [1, 2, 3]))
        .timestamp()
        .listen(expectAsync1((result) {
          expect(result.value, expected[count++]);
        }, count: expected.length));
  });

  test('Rx.Observable.timestamp.reusable', () async {
    final transformer = new TimestampStreamTransformer<int>();
    const expected = [1, 2, 3];
    var countA = 0, countB = 0;

    new Observable(new Stream.fromIterable(const [1, 2, 3]))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result.value, expected[countA++]);
        }, count: expected.length));

    new Observable(new Stream.fromIterable(const [1, 2, 3]))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result.value, expected[countB++]);
        }, count: expected.length));
  });

  test('timestampTransformer', () async {
    const expected = [1, 2, 3];
    var count = 0;

    new Stream.fromIterable(const [1, 2, 3])
        .transform(new TimestampStreamTransformer<int>())
        .listen(expectAsync1((result) {
          expect(result.value, expected[count++]);
        }, count: expected.length));
  });

  test('timestampTransformer.asBroadcastStream', () async {
    final stream = new Stream.fromIterable(const [1, 2, 3])
        .transform(new TimestampStreamTransformer<int>())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('timestampTransformer.error.shouldThrow', () async {
    final streamWithError = new ErrorStream<int>(new Exception())
        .transform(new TimestampStreamTransformer());

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('timestampTransformer.pause.resume', () async {
    final stream = new Stream.fromIterable(const [1, 2, 3])
        .transform(new TimestampStreamTransformer());
    const expected = [1, 2, 3];
    StreamSubscription<Timestamped<int>> subscription;
    var count = 0;

    subscription = stream.listen(expectAsync1((result) {
      expect(result.value, expected[count++]);

      if (count == expected.length) {
        subscription.cancel();
      }
    }, count: expected.length));

    subscription.pause();
    subscription.resume();
  });
}
