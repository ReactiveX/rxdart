import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

void main() {
  test('rx.Observable.delay', () async {
    int value = 1;
    new Observable<int>(_getStream())
        .delay(const Duration(milliseconds: 200))
        .listen(expectAsync1((int result) {
          expect(result, value++);
        }, count: 4));
  });

  test('rx.Observable.delay.shouldBeDelayed', () async {
    int value = 1;
    new Observable<int>(_getStream())
        .delay(const Duration(milliseconds: 500))
        .timeInterval()
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(result.value, value++);

          if (result.value == 1)
            expect(result.interval.inMilliseconds,
                greaterThanOrEqualTo(500)); // should be delayed
          else
            expect(result.interval.inMilliseconds,
                lessThanOrEqualTo(20)); // should be near instantaneous
        }, count: 4));
  });

  test('rx.Observable.delay.reusable', () async {
    final DelayStreamTransformer<int> transformer =
        new DelayStreamTransformer<int>(const Duration(milliseconds: 200));
    int valueA = 1, valueB = 1;

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, valueA++);
        }, count: 4));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, valueB++);
        }, count: 4));
  });

  test('rx.Observable.delay.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .delay(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.delay.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .delay(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  /// Should also throw if the current [Zone] is unable to install a [Timer]
  test('rx.Observable.delay.error.shouldThrowB', () async {
    runZoned(() {
      Stream<num> observableWithError =
          new Observable<int>.just(1).delay(const Duration(milliseconds: 200));

      observableWithError.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (Zone self, ZoneDelegate parent, Zone zone,
                    Duration duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });

  test('rx.Observable.delay.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = new Observable<int>.fromIterable(<int>[1, 2, 3])
        .delay(new Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test(
    'rx.Observable.delay.cancel.emits.nothing',
    () async {
      StreamSubscription<int> subscription;
      Observable<int> stream =
          new Observable<int>.fromIterable(<int>[1, 2, 3]).doOnDone(() {
        subscription.cancel();
      }).delay(new Duration(seconds: 10));

      // We expect the onData callback to be called 0 times because the
      // subscription is cancelled when the base stream ends.
      subscription = stream.listen(expectAsync1((int val) {}, count: 0));
    },
    timeout: new Timeout(new Duration(seconds: 3)),
  );
}
