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
  test('rx.Observable.throttle', () async {
    const List<int> expectedOutput = const <int>[1, 4];
    int count = 0;

    new Observable<int>(_getStream())
        .throttle(const Duration(milliseconds: 250))
        .listen(expectAsync1((int result) {
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.throttle.reusable', () async {
    final ThrottleStreamTransformer<int> transformer =
        new ThrottleStreamTransformer<int>(const Duration(milliseconds: 250));
    const List<int> expectedOutput = const <int>[1, 4];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, expectedOutput[countA++]);
        }, count: 2));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, expectedOutput[countB++]);
        }, count: 2));
  });

  test('rx.Observable.throttle.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .throttle(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.throttle.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .throttle(const Duration(milliseconds: 200));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.throttle.error.shouldThrowB', () {
    expect(
        () => new Observable<num>.just(1).throttle(null), throwsArgumentError);
  });

  test('rx.Observable.throttle.error.shouldThrowC', () async {
    runZoned(() {
      Stream<num> observable = new Observable<int>.just(1)
          .throttle(const Duration(milliseconds: 200));

      observable.listen(null,
          onError: expectAsync2(
              (Exception e, StackTrace s) => expect(e, isException)));
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (Zone self, ZoneDelegate parent, Zone zone,
                    Duration duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });

  test('rx.Observable.throttle.pause.resume', () async {
    StreamSubscription<int> subscription;
    const List<int> expectedOutput = const <int>[1, 4];
    int count = 0;

    subscription = new Observable<int>(_getStream())
        .throttle(const Duration(milliseconds: 250))
        .listen(expectAsync1((int result) {
          expect(result, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
