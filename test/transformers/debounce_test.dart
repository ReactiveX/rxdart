import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 100), () => controller.add(1));
  Timer(const Duration(milliseconds: 200), () => controller.add(2));
  Timer(const Duration(milliseconds: 300), () => controller.add(3));
  Timer(const Duration(milliseconds: 400), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.debounce', () async {
    Observable(_getStream())
        .debounce(const Duration(milliseconds: 200))
        .listen(expectAsync1((result) {
          expect(result, 4);
        }, count: 1));
  });

  test('rx.Observable.debounce.reusable', () async {
    final transformer =
        DebounceStreamTransformer<int>(const Duration(milliseconds: 200));

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, 4);
        }, count: 1));

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, 4);
        }, count: 1));
  });

  test('rx.Observable.debounce.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream())
        .debounce(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.debounce.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .debounce(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  /// Should also throw if the current [Zone] is unable to install a [Timer]
  test('rx.Observable.debounce.error.shouldThrowB', () async {
    runZoned(() {
      final observableWithError =
          Observable.just(1).debounce(const Duration(milliseconds: 200));

      observableWithError.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: ZoneSpecification(
            createTimer: (self, parent, zone, duration, void f()) =>
                throw Exception('Zone createTimer error')));
  });

  test('rx.Observable.debounce.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream = Observable.fromIterable(const [1, 2, 3])
        .debounce(Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 3);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.debounce.emits.last.item.immediately', () async {
    final emissions = <int>[];
    final stopwatch = Stopwatch();
    final stream = Observable.fromIterable(const [1, 2, 3])
        .debounce(Duration(seconds: 100));

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
  }, timeout: Timeout(Duration(seconds: 3)));

  test(
    'rx.Observable.debounce.cancel.emits.nothing',
    () async {
      StreamSubscription<int> subscription;
      final stream = Observable.fromIterable(const [1, 2, 3]).doOnDone(() {
        subscription.cancel();
      }).debounce(Duration(seconds: 10));

      // We expect the onData callback to be called 0 times because the
      // subscription is cancelled when the base stream ends.
      subscription = stream.listen(expectAsync1((_) {}, count: 0));
    },
    timeout: Timeout(Duration(seconds: 3)),
  );
}
