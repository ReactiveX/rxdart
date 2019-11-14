import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('ExhaustMap', () {
    test('does not create a new Stream while emitting', () async {
      var calls = 0;
      final observable = Observable.range(0, 9).exhaustMap((i) {
        calls++;
        return Observable.timer(i, Duration(milliseconds: 100));
      });

      await expectLater(observable, emitsInOrder(<dynamic>[0, emitsDone]));
      await expectLater(calls, 1);
    });

    test('starts emitting again after previous Stream is complete', () async {
      final observable =
          Observable.fromIterable(const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
              .interval(Duration(milliseconds: 30))
              .exhaustMap((i) async* {
        yield await Future.delayed(Duration(milliseconds: 70), () => i);
      });

      await expectLater(
          observable, emitsInOrder(<dynamic>[0, 3, 6, 9, emitsDone]));
    });

    test('is reusable', () async {
      final transformer = ExhaustMapStreamTransformer(
          (int i) => Observable.timer(i, Duration(milliseconds: 100)));

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
      final stream = Observable.range(0, 9)
          .asBroadcastStream()
          .exhaustMap((i) => Observable.timer(i, Duration(milliseconds: 100)));

      await expectLater(() {
        stream.listen(null);
        stream.listen(null);
      }, returnsNormally);
    });

    test('should emit errors from source', () async {
      final observableWithError = Observable(ErrorStream<int>(Exception()))
          .exhaustMap((i) => Observable.timer(i, Duration(milliseconds: 100)));

      await expectLater(observableWithError, emitsError(isException));
    });

    test('should emit errors from mapped stream', () async {
      final observableWithError = Observable.just(1).exhaustMap(
          (_) => ErrorStream<void>(Exception('Catch me if you can!')));

      await expectLater(observableWithError, emitsError(isException));
    });

    test('should emit errors thrown in the mapper', () async {
      final observableWithError = Observable.just(1).exhaustMap<void>((_) {
        throw Exception('oh noes!');
      });

      await expectLater(observableWithError, emitsError(isException));
    });

    test('can be paused and resumed', () async {
      StreamSubscription<int> subscription;
      final stream = Observable.range(0, 9)
          .exhaustMap((i) => Observable.timer(i, Duration(milliseconds: 20)));

      subscription = stream.listen(expectAsync1((value) {
        expect(value, 0);
        subscription.cancel();
      }, count: 1));

      subscription.pause();
      subscription.resume();
    });
  });
}
