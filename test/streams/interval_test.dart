import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/streams/interval.dart';
import 'package:test/test.dart';

void main() {
  test('IntervalStream', () async {
    final stream = IntervalStream(Duration(milliseconds: 1)).take(3);

    await expectLater(stream, emitsInOrder(<dynamic>[0, 1, 2, emitsDone]));
  });

  test('IntervalStream.single.subscription', () async {
    final stream = IntervalStream(Duration(milliseconds: 1));

    stream.listen(null);
    await expectLater(() => stream.listen(null), throwsA(isStateError));
  });

  test('IntervalStream.pause.resume', () async {
    StreamSubscription<int> subscription;

    var iteration = 0;
    final stream = IntervalStream(Duration(milliseconds: 1)).take(3);

    subscription = stream.listen(expectAsync1((actual) {
      expect(actual, iteration);
      iteration++;
    }, count: 3));

    subscription.pause();
    subscription.resume();
  });

  test('IntervalStream.single.subscription', () async {
    final stream = IntervalStream(Duration(milliseconds: 1));

    try {
      stream.listen(null);
      stream.listen(null);
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });

  test('IntervalStream.cancel', () async {
    StreamSubscription<int> subscription;

    final stream = IntervalStream(Duration(milliseconds: 1));

    subscription = stream.listen(
        expectAsync1((_) {
          expect(true, isFalse);
        }, count: 0),
        onError: expectAsync2((Exception e, StackTrace s) {
          expect(true, isFalse);
        }, count: 0),
        onDone: expectAsync0(() {
          expect(true, isFalse);
        }, count: 0));

    await subscription.cancel();
  });
}