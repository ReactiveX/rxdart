import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final controller = new StreamController<int>();

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
  test('rx.Observable.throttle', () async {
    const expectedOutput = [1, 4];
    var count = 0;

    new Observable(_getStream())
        .throttle(const Duration(milliseconds: 250))
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.throttle.reusable', () async {
    final transformer =
        new ThrottleStreamTransformer<int>(const Duration(milliseconds: 250));
    const expectedOutput = const [1, 4];
    var countA = 0, countB = 0;

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: 2));

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: 2));
  });

  test('rx.Observable.throttle.asBroadcastStream', () async {
    final stream = new Observable(_getStream().asBroadcastStream())
        .throttle(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.throttle.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception()))
            .throttle(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.throttle.error.shouldThrowB', () {
    expect(() => new Observable.just(1).throttle(null), throwsArgumentError);
  });

  test('rx.Observable.throttle.error.shouldThrowC', () async {
    runZoned(() {
      final observable =
          new Observable.just(1).throttle(const Duration(milliseconds: 200));

      observable.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (self, parent, zone, duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });

  test('rx.Observable.throttle.pause.resume', () async {
    StreamSubscription<int> subscription;
    const expectedOutput = [1, 4];
    var count = 0;

    subscription = new Observable(_getStream())
        .throttle(const Duration(milliseconds: 250))
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
