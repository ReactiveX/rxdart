import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.defaultIfEmpty.whenEmpty', () async {
    new Observable(new Stream<bool>.empty())
        .defaultIfEmpty(true)
        .listen(expectAsync1((bool result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.defaultIfEmpty.reusable', () async {
    final transformer = new DefaultIfEmptyStreamTransformer<bool>(true);

    new Observable(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));

    new Observable(new Stream<bool>.empty())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, true);
        }, count: 1));
  });

  test('rx.Observable.defaultIfEmpty.whenNotEmpty', () async {
    new Observable(new Stream.fromIterable(const [false, false, false]))
        .defaultIfEmpty(true)
        .listen(expectAsync1((result) {
          expect(result, false);
        }, count: 3));
  });

  test('rx.Observable.defaultIfEmpty.asBroadcastStream', () async {
    final stream = new Observable.fromIterable(const <int>[])
        .defaultIfEmpty(-1)
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);

    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.defaultIfEmpty.error.shouldThrow', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .defaultIfEmpty(-1);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.defaultIfEmpty.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream = new Observable.fromIterable(const <int>[]).defaultIfEmpty(1);

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
