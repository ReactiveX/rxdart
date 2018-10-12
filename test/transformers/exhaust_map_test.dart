import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/exhaust_map.dart';
import 'package:test/test.dart';

void main() {
  group('ExhaustMap', () {
    test('does not create a new Stream while emitting', () async {
      int calls = 0;
      final Observable<int> observable =
          Observable.range(0, 9).exhaustMap((int i) {
        calls++;
        return new Observable<int>.timer(i, new Duration(milliseconds: 100));
      });

      await expectLater(observable, emitsInOrder(<dynamic>[0, emitsDone]));
      await expectLater(calls, 1);
    });

    test('starts emitting again after previous Stream is complete', () async {
      int calls = 0;
      final Observable<int> observable = Observable.range(0, 9)
          .interval(new Duration(milliseconds: 20))
          .exhaustMap((int i) {
        calls++;
        return new Observable<int>.timer(i, new Duration(milliseconds: 100));
      });

      await expectLater(observable, emitsInOrder(<dynamic>[0, 5, emitsDone]));
      await expectLater(calls, 2);
    });

    test('is reusable', () async {
      final ExhaustMapStreamTransformer<int, int> transformer =
          new ExhaustMapStreamTransformer<int, int>((int i) =>
              new Observable<int>.timer(i, new Duration(milliseconds: 100)));

      await expectLater(
        Observable.range(0, 9).transform(transformer),
        emitsInOrder(<dynamic>[0, emitsDone]),
      );

      await expectLater(
        Observable.range(0, 9).transform(transformer),
        emitsInOrder(<dynamic>[0, emitsDone]),
      );
    });

    test('works as a broadcast stream', () async {
      Stream<num> stream = Observable.range(0, 9)
          .asBroadcastStream()
          .exhaustMap((int i) =>
              new Observable<int>.timer(i, new Duration(milliseconds: 100)));

      await expectLater(() {
        stream.listen((_) {});
        stream.listen((_) {});
      }, returnsNormally);
    });

    test('should emit errors from source', () async {
      Stream<int> observableWithError = new Observable<int>(
              new ErrorStream<int>(new Exception()))
          .exhaustMap((int i) =>
              new Observable<int>.timer(i, new Duration(milliseconds: 100)));

      await expectLater(observableWithError, emitsError(isException));
    });

    test('should emit errors from mapped stream', () async {
      Stream<int> observableWithError = new Observable<int>.just(1).exhaustMap(
          (_) => new ErrorStream<int>(new Exception('Catch me if you can!')));

      await expectLater(observableWithError, emitsError(isException));
    });

    test('should emit errors thrown in the mapper', () async {
      Stream<int> observableWithError =
          new Observable<int>.just(1).exhaustMap((_) {
        throw new Exception('oh noes!');
      });

      await expectLater(observableWithError, emitsError(isException));
    });

    test('can be paused and resumed', () async {
      StreamSubscription<int> subscription;
      Observable<int> stream = Observable.range(0, 9).exhaustMap((int i) =>
          new Observable<int>.timer(i, new Duration(milliseconds: 20)));

      subscription = stream.listen(expectAsync1((int value) {
        expect(value, 0);
        subscription.cancel();
      }, count: 1));

      subscription.pause();
      subscription.resume();
    });
  });
}
