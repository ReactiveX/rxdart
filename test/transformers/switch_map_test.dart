import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 10), () => controller.add(1));
  Timer(const Duration(milliseconds: 20), () => controller.add(2));
  Timer(const Duration(milliseconds: 30), () => controller.add(3));
  Timer(const Duration(milliseconds: 40), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> _getOtherStream(int value) {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 15), () => controller.add(value + 1));
  Timer(const Duration(milliseconds: 25), () => controller.add(value + 2));
  Timer(const Duration(milliseconds: 35), () => controller.add(value + 3));
  Timer(const Duration(milliseconds: 45), () {
    controller.add(value + 4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> range() =>
    Stream.fromIterable(const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

void main() {
  test('rx.Observable.switchMap', () async {
    const expectedOutput = [5, 6, 7, 8];
    var count = 0;

    Observable(_getStream())
        .switchMap(_getOtherStream)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.switchMap.reusable', () async {
    final transformer = SwitchMapStreamTransformer<int, int>(_getOtherStream);
    const expectedOutput = [5, 6, 7, 8];
    var countA = 0, countB = 0;

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length));

    Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.switchMap.asBroadcastStream', () async {
    final stream =
        Observable(_getStream().asBroadcastStream()).switchMap(_getOtherStream);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.switchMap.error.shouldThrowA', () async {
    final observableWithError =
        Observable(ErrorStream<int>(Exception())).switchMap(_getOtherStream);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.switchMap.error.shouldThrowB', () async {
    final observableWithError = Observable.just(1)
        .switchMap((_) => ErrorStream<void>(Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.switchMap.error.shouldThrowC', () async {
    final observableWithError = Observable.just(1).switchMap<void>((_) {
      throw Exception('oh noes!');
    });

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.switchMap.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream = Observable.just(0).switchMap((_) => Observable.just(1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
