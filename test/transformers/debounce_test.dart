import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.debounce', () async {
    new Observable<int>(_getStream())
        .debounce(const Duration(milliseconds: 200))
        .listen(expectAsync1((int result) {
          expect(result, 4);
        }, count: 1));
  });

  test('rx.Observable.debounce.reusable', () async {
    final DebounceStreamTransformer<int> transformer =
        new DebounceStreamTransformer<int>(const Duration(milliseconds: 200));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, 4);
        }, count: 1));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, 4);
        }, count: 1));
  });

  test('rx.Observable.debounce.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .debounce(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.debounce.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .debounce(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  /// Should also throw if the current [Zone] is unable to install a [Timer]
  test('rx.Observable.debounce.error.shouldThrowB', () async {
    runZoned(() {
      Stream<num> observableWithError = new Observable<int>.just(1)
          .debounce(const Duration(milliseconds: 200));

      observableWithError.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (Zone self, ZoneDelegate parent, Zone zone,
                    Duration duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });

  test('rx.Observable.debounce.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = new Observable<int>.fromIterable(<int>[1, 2, 3])
        .debounce(new Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 3);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.debounce.emits.last.item.immediately', () async {
    List<dynamic> emissions = <dynamic>[];
    Stopwatch stopwatch = new Stopwatch();
    Observable<int> stream = new Observable<int>.fromIterable(<int>[1, 2, 3])
        .debounce(new Duration(seconds: 100));

    stopwatch.start();

    stream.listen(
        expectAsync1((int val) {
          emissions.add(val);
        }, count: 1), onDone: expectAsync0(() {
      stopwatch.stop();

      expect(emissions, <int>[3]);

      // We debounce for 100 seconds. To ensure we aren't waiting that long to
      // emit the last item after the base stream completes, we expect the
      // last value to be emitted to be much shorter than that.
      expect(stopwatch.elapsedMilliseconds < 500, isTrue);
    }));
  }, timeout: new Timeout(new Duration(seconds: 3)));

  test(
    'rx.Observable.debounce.cancel.emits.nothing',
    () async {
      StreamSubscription<int> subscription;
      Observable<int> stream =
          new Observable<int>.fromIterable(<int>[1, 2, 3]).doOnDone(() {
        subscription.cancel();
      }).debounce(new Duration(seconds: 10));

      // We expect the onData callback to be called 0 times because the
      // subscription is cancelled when the base stream ends.
      subscription = stream.listen(expectAsync1((int val) {}, count: 0));
    },
    timeout: new Timeout(new Duration(seconds: 3)),
  );
}
