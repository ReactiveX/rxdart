import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> get ticker =>
    Observable.periodic(const Duration(milliseconds: 100), (step) => step + 1);

void main() {
  test('rx.Observable.debounce.static', () async {
    await expectLater(
        ticker.take(4).debounce(const Duration(milliseconds: 200)),
        emitsInOrder(<dynamic>[4, emitsDone]));
  });

  test('rx.Observable.debounce.selector', () async {
    await expectLater(
        ticker.take(4).debounceSelector((i) => i == 1
            ? const Duration(milliseconds: 50)
            : const Duration(seconds: 1)),
        emitsInOrder(<dynamic>[1, 4, emitsDone]));
  });

  test('rx.Observable.debounce.reusable', () async {
    final transformer = new DebounceStreamTransformer<int>(
        (_) => const Duration(milliseconds: 200));

    await expectLater(ticker.take(4).transform(transformer),
        emitsInOrder(<dynamic>[4, emitsDone]));

    await expectLater(ticker.take(4).transform(transformer),
        emitsInOrder(<dynamic>[4, emitsDone]));
  });

  test('rx.Observable.debounce.asBroadcastStream', () async {
    final stream = ticker
        .take(4)
        .asBroadcastStream()
        .debounce(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(stream, emitsInOrder(<dynamic>[4, emitsDone]));
  });

  test('rx.Observable.debounce.error.shouldThrowA', () async {
    final observableWithError =
        Observable(new ErrorStream<void>(new Exception()))
            .debounce(const Duration(milliseconds: 200));

    await expectLater(
        observableWithError,
        emitsInOrder(
            <dynamic>[emitsError(new TypeMatcher<Exception>()), emitsDone]));
  });

  /// Should also throw if the current [Zone] is unable to install a [Timer]
  test('rx.Observable.debounce.error.shouldThrowB', () async {
    runZoned(() {
      final singleEventTicker =
          Observable.just(1).debounce(const Duration(milliseconds: 200));

      singleEventTicker.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (self, parent, zone, duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });

  test('rx.Observable.debounce.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream = new Observable.fromIterable(const [1, 2, 3])
        .debounce(const Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 3);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.debounce.emits.last.item.immediately', () async {
    final emissions = <int>[];
    final stopwatch = new Stopwatch();
    final stream = new Observable.fromIterable(const [1, 2, 3])
        .debounce(const Duration(seconds: 100));

    stopwatch.start();

    stream.listen(
        expectAsync1((val) {
          emissions.add(val);
        }, count: 1), onDone: expectAsync0(() {
      stopwatch.stop();

      expect(emissions, const [3]);

      // We debounce for 100 seconds. To ensure we aren't waiting that long to
      // emit the last item after the base stream completes, we expect the
      // last value to be emitted to be much shorter than that.
      expect(stopwatch.elapsedMilliseconds < 500, isTrue);
    }));
  }, timeout: new Timeout(const Duration(seconds: 3)));

  test(
    'rx.Observable.debounce.cancel.emits.nothing',
    () async {
      StreamSubscription<int> subscription;
      final stream = new Observable.fromIterable(const [1, 2, 3])
          .doOnDone(() => subscription.cancel())
          .debounce(const Duration(seconds: 10));

      // We expect the onData callback to be called 0 times because the
      // subscription is cancelled when the base stream ends.
      subscription = stream.listen(expectAsync1((_) {}, count: 0));
    },
    timeout: new Timeout(const Duration(seconds: 3)),
  );

  test('rx.Observable.debounce.nullTimeout.emitsImmediately', () async {
    await expectLater(ticker.take(4).debounce(null),
        emitsInOrder(<dynamic>[1, 2, 3, 4, emitsDone]));
  });

  test('rx.Observable.debounce.nullTimeout.emitsImmediately.asSelector',
      () async {
    await expectLater(ticker.take(4).debounceSelector((_) => null),
        emitsInOrder(<dynamic>[1, 2, 3, 4, emitsDone]));
  });
}
