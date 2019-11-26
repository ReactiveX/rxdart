import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('TimerStream', () async {
    const value = 1;

    final stream = TimerStream(value, Duration(milliseconds: 1));

    await expectLater(stream, emitsInOrder(<dynamic>[value, emitsDone]));
  });

  test('TimerStream.single.subscription', () async {
    final stream = TimerStream(1, Duration(milliseconds: 1));

    stream.listen(null);
    await expectLater(() => stream.listen(null), throwsA(isStateError));
  });

  test('TimerStream.pause.resume', () async {
    const value = 1;
    StreamSubscription<int> subscription;

    final stream = TimerStream(value, Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((actual) {
      expect(actual, value);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });

  test('TimerStream.single.subscription', () async {
    final stream = TimerStream(null, Duration(milliseconds: 1));

    try {
      stream.listen(null);
      stream.listen(null);
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });

  test('TimerStream.cancel', () async {
    const value = 1;
    StreamSubscription<int> subscription;

    final stream = TimerStream(value, Duration(milliseconds: 1));

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

  test('Rx.timer', () async {
    const value = 1;

    final stream = Rx.timer(value, Duration(milliseconds: 5));

    stream.listen(expectAsync1((actual) {
      expect(actual, value);
    }), onDone: expectAsync0(() {
      expect(true, isTrue);
    }));
  });
}
