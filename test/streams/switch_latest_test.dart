import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('SwitchLatest', () {
    test('emits all values from an emitted Stream', () {
      expect(
        new Observable<String>.switchLatest(
          new Observable<Stream<String>>.just(
            new Stream<String>.fromIterable(<String>['A', 'B', 'C']),
          ),
        ),
        emitsInOrder(<dynamic>['A', 'B', 'C', emitsDone]),
      );
    });

    test('only emits values from the latest emitted stream', () {
      expect(
        new Observable<String>.switchLatest(testObservable),
        emits('C'),
      );
    });

    test('emits errors from the higher order Stream to the listener', () {
      expect(
        new Observable<String>.switchLatest(
          new Observable<Stream<String>>.error(new Exception()),
        ),
        emitsError(isException),
      );
    });

    test('emits errors from the emitted Stream to the listener', () {
      expect(
        new Observable<String>.switchLatest(errorObservable),
        emitsError(isException),
      );
    });

    test('closes after the last event from the last emitted Stream', () {
      expect(
        new Observable<String>.switchLatest(testObservable),
        emitsThrough(emitsDone),
      );
    });

    test('closes if the higher order stream is empty', () {
      expect(
        new Observable<String>.switchLatest(
          new Observable<Stream<String>>.empty(),
        ),
        emitsThrough(emitsDone),
      );
    });

    test('is single subscription', () {
      final SwitchLatestStream<String> stream =
          new SwitchLatestStream<String>(testObservable);

      expect(stream, emits('C'));
      expect(() => stream.listen(null), throwsStateError);
    });

    test('can be paused and resumed', () {
      // ignore: cancel_subscriptions
      final StreamSubscription<String> subscription =
          new Observable<String>.switchLatest(testObservable)
              .listen(expectAsync1((String result) {
        expect(result, 'C');
      }));

      subscription.pause();
      subscription.resume();
    });
  });
}

Observable<Stream<String>> get testObservable =>
    new Observable<Stream<String>>.fromIterable(<Stream<String>>[
      new Observable<String>.timer('A', new Duration(seconds: 2)),
      new Observable<String>.timer('B', new Duration(seconds: 1)),
      new Observable<String>.just('C'),
    ]);

Observable<Stream<String>> get errorObservable =>
    new Observable<Stream<String>>.fromIterable(<Stream<String>>[
      new Observable<String>.timer('A', new Duration(seconds: 2)),
      new Observable<String>.timer('B', new Duration(seconds: 1)),
      new Observable<String>.error(new Exception()),
    ]);
