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

  test('TimerStream.delay.startAfterListen', () async {
    final stream = TimerStream(1, const Duration(milliseconds: 10));
    await Future<void>.delayed(const Duration(seconds: 1));

    await expectLater(stream, emitsInOrder(<dynamic>[1, emitsDone]));
  });

  test('rx.Observable.timer', () async {
    const value = 1;

    final observable = Observable.timer(value, Duration(milliseconds: 5));

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }), onDone: expectAsync0(() {
      expect(true, isTrue);
    }));
  });

  /// Should also throw if the current [Zone] is unable to install a [Timer]
  test('rx.Observable.timer.error.zone', () async {
    runZoned(() {
      final stream = TimerStream(null, const Duration(milliseconds: 200));

      stream.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: ZoneSpecification(
            createTimer: (self, parent, zone, duration, void f()) =>
                throw Exception('Zone createTimer error')));
  });

  test('rx.Observable.timer.error.debounce.assertNotNull', () async {
    runZoned(() {
      final stream = TimerStream(null, null);

      stream.listen(null,
          onError: expectAsync2((Error e, StackTrace s) =>
              expect(e, const TypeMatcher<AssertionError>())));
    });
  }, skip: true);
}
