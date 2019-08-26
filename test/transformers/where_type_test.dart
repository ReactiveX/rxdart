import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<Object> _getStream() {
  final controller = StreamController<dynamic>();

  Timer(const Duration(milliseconds: 100), () => controller.add(1));
  Timer(const Duration(milliseconds: 200), () => controller.add('2'));
  Timer(
      const Duration(milliseconds: 300), () => controller.add(const {'3': 3}));
  Timer(const Duration(milliseconds: 400), () {
    controller.add(const {'4': '4'});
  });
  Timer(const Duration(milliseconds: 500), () {
    controller.add(5.0);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.whereType', () async {
    Observable(_getStream())
        .whereType<Map<String, int>>()
        .listen(expectAsync1((result) {
          expect(result, isMap);
        }, count: 1));
  });

  test('rx.Observable.whereType.polymorphism', () async {
    Observable(_getStream()).whereType<num>().listen(expectAsync1((result) {
          expect(result is num, true);
        }, count: 2));
  });

  test('rx.Observable.whereType.null.values', () async {
    await expectLater(
        Observable.fromIterable([null, 1, null, 'two', 3]).whereType<String>(),
        emitsInOrder(const <String>['two']));
  });

  test('rx.Observable.whereType.asBroadcastStream', () async {
    final stream =
        Observable(_getStream().asBroadcastStream()).whereType<int>();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.whereType.error.shouldThrow', () async {
    final observableWithError =
        Observable(ErrorStream<void>(Exception())).whereType<num>();

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.whereType.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream = Observable.just(1).whereType<int>();

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
