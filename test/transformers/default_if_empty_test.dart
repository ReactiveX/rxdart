import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.defaultIfEmpty.whenEmpty', () async {
    new Observable<bool>(new Stream<bool>.empty())
        .defaultIfEmpty(true)
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.defaultIfEmpty.reusable', () async {
    final DefaultIfEmptyStreamTransformer<bool> transformer =
        new DefaultIfEmptyStreamTransformer<bool>(true);

    new Observable<bool>(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));

    new Observable<bool>(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.defaultIfEmpty.whenNotEmpty', () async {
    new Observable<bool>(
            new Stream<bool>.fromIterable(const <bool>[false, false, false]))
        .defaultIfEmpty(true)
        .listen(expectAsync1((bool result) {
          expect(result, false);
        }, count: 3));
  });

  test('rx.Observable.defaultIfEmpty.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>.fromIterable(<int>[])
        .defaultIfEmpty(-1)
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});

    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.defaultIfEmpty.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .defaultIfEmpty(-1);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.defaultIfEmpty.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream =
        new Observable<int>.fromIterable(<int>[]).defaultIfEmpty(1);

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
