import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('SwitchLatest', () {
    test('emits all values from an emitted Stream', () {
      expect(
        new Observable.switchLatest(
          new Observable.just(
            new Stream.fromIterable(const ['A', 'B', 'C']),
          ),
        ),
        emitsInOrder(<dynamic>['A', 'B', 'C', emitsDone]),
      );
    });

    test('only emits values from the latest emitted stream', () {
      expect(
        new Observable.switchLatest(testObservable),
        emits('C'),
      );
    });

    test('emits errors from the higher order Stream to the listener', () {
      expect(
        new Observable.switchLatest(
          new Observable<Stream<void>>.error(new Exception()),
        ),
        emitsError(isException),
      );
    });

    test('emits errors from the emitted Stream to the listener', () {
      expect(
        new Observable.switchLatest(errorObservable),
        emitsError(isException),
      );
    });

    test('closes after the last event from the last emitted Stream', () {
      expect(
        new Observable.switchLatest(testObservable),
        emitsThrough(emitsDone),
      );
    });

    test('closes if the higher order stream is empty', () {
      expect(
        new Observable.switchLatest(
          new Observable<Stream<void>>.empty(),
        ),
        emitsThrough(emitsDone),
      );
    });

    test('is single subscription', () {
      final stream = new SwitchLatestStream(testObservable);

      expect(stream, emits('C'));
      expect(() => stream.listen(null), throwsStateError);
    });

    test('can be paused and resumed', () {
      // ignore: cancel_subscriptions
      final subscription = new Observable.switchLatest(testObservable)
          .listen(expectAsync1((result) {
        expect(result, 'C');
      }));

      subscription.pause();
      subscription.resume();
    });
  });
}

Observable<Stream<String>> get testObservable => new Observable.fromIterable([
      new Observable.timer('A', new Duration(seconds: 2)),
      new Observable.timer('B', new Duration(seconds: 1)),
      new Observable.just('C'),
    ]);

Observable<Stream<String>> get errorObservable => new Observable.fromIterable([
      new Observable.timer('A', new Duration(seconds: 2)),
      new Observable.timer('B', new Duration(seconds: 1)),
      new Observable.error(new Exception()),
    ]);
