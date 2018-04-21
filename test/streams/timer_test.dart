import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('TimerStream', () async {
    const int value = 1;

    Stream<int> stream =
        new TimerStream<int>(value, new Duration(milliseconds: 1));

    await expectLater(stream, emitsInOrder(<dynamic>[value, emitsDone]));
  });

  test('TimerStream.single.subscription', () async {
    Stream<int> stream = new TimerStream<int>(1, new Duration(milliseconds: 1));

    stream.listen((_) {});
    await expectLater(() => stream.listen((_) {}), throwsA(isStateError));
  });

  test('TimerStream.pause.resume', () async {
    const int value = 1;
    StreamSubscription<int> subscription;

    Stream<int> stream =
        new TimerStream<int>(value, new Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((int actual) {
      expect(actual, value);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });

  test('TimerStream.cancel', () async {
    const int value = 1;
    StreamSubscription<int> subscription;

    Stream<int> stream =
        new TimerStream<int>(value, new Duration(milliseconds: 1));

    subscription = stream.listen(
        expectAsync1((int actual) {
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

  test('rx.Observable.timer', () async {
    const int value = 1;

    Stream<int> observable =
        new Observable<int>.timer(value, new Duration(milliseconds: 5));

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }), onDone: expectAsync0(() {
      expect(true, isTrue);
    }));
  });
}
