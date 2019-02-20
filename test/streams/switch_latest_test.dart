import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('SwitchLatest', () {
    test('emits all values from an emitted Stream', () {
      expect(
        Observable.switchLatest(
          Observable.just(
            Stream.fromIterable(const ['A', 'B', 'C']),
          ),
        ),
        emitsInOrder(<dynamic>['A', 'B', 'C', emitsDone]),
      );
    });

    test('only emits values from the latest emitted stream', () {
      expect(
        Observable.switchLatest(testObservable),
        emits('C'),
      );
    });

    test('emits errors from the higher order Stream to the listener', () {
      expect(
        Observable.switchLatest(
          Observable<Stream<void>>.error(Exception()),
        ),
        emitsError(isException),
      );
    });

    test('emits errors from the emitted Stream to the listener', () {
      expect(
        Observable.switchLatest(errorObservable),
        emitsError(isException),
      );
    });

    test('closes after the last event from the last emitted Stream', () {
      expect(
        Observable.switchLatest(testObservable),
        emitsThrough(emitsDone),
      );
    });

    test('closes if the higher order stream is empty', () {
      expect(
        Observable.switchLatest(
          Observable<Stream<void>>.empty(),
        ),
        emitsThrough(emitsDone),
      );
    });

    test('is single subscription', () {
      final stream = SwitchLatestStream(testObservable);

      expect(stream, emits('C'));
      expect(() => stream.listen(null), throwsStateError);
    });

    test('can be paused and resumed', () {
      // ignore: cancel_subscriptions
      final subscription =
          Observable.switchLatest(testObservable).listen(expectAsync1((result) {
        expect(result, 'C');
      }));

      subscription.pause();
      subscription.resume();
    });
  });
}

Observable<Stream<String>> get testObservable => Observable.fromIterable([
      Observable.timer('A', Duration(seconds: 2)),
      Observable.timer('B', Duration(seconds: 1)),
      Observable.just('C'),
    ]);

Observable<Stream<String>> get errorObservable => Observable.fromIterable([
      Observable.timer('A', Duration(seconds: 2)),
      Observable.timer('B', Duration(seconds: 1)),
      Observable.error(Exception()),
    ]);
