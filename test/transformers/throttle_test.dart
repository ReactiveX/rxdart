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
  test('rx.Observable.throttle', () async {
    const expectedOutput = [1, 4];
    var count = 0;

    Observable(_getStream())
        .throttle(const Duration(milliseconds: 250))
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.throttle.reusable', () async {
    final transformer =
        ThrottleStreamTransformer<int>(const Duration(milliseconds: 250));
    const expectedOutput = [1, 4];
    var countA = 0, countB = 0;

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: 2));

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: 2));
  });

  test('rx.Observable.throttle.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream())
        .throttle(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.throttle.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .throttle(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.throttle.error.shouldThrowB', () {
    expect(() => Observable.just(1).throttle(null), throwsArgumentError);
  });

  test('rx.Observable.throttle.error.shouldThrowC', () async {
    runZoned(() {
      final observable =
          Observable.just(1).throttle(const Duration(milliseconds: 200));

      observable.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: ZoneSpecification(
            createTimer: (self, parent, zone, duration, void f()) =>
                throw Exception('Zone createTimer error')));
  });

  test('rx.Observable.throttle.pause.resume', () async {
    StreamSubscription<int> subscription;
    const expectedOutput = [1, 4];
    var count = 0;

    subscription = Observable(_getStream())
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
