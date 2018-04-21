import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/type_token.dart';
import 'package:test/test.dart';

Stream<dynamic> _getStream() {
  StreamController<dynamic> controller = new StreamController<dynamic>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add('2'));
  new Timer(const Duration(milliseconds: 300),
      () => controller.add(<String, int>{'3': 3}));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(<String, String>{'4': '4'});
  });
  new Timer(const Duration(milliseconds: 500), () {
    controller.add(5.0);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.ofType', () async {
    new Observable<dynamic>(_getStream())
        .ofType(new TypeToken<Map<String, int>>())
        .listen(expectAsync1((Map<String, int> result) {
          expect(result, isMap);
        }, count: 1));
  });

  test('rx.Observable.ofType.polymorphism', () async {
    new Observable<dynamic>(_getStream())
        .ofType(kNum)
        .listen(expectAsync1((num result) {
          expect(result is num, true);
        }, count: 2));
  });

  test('rx.Observable.ofType.asBroadcastStream', () async {
    Stream<int> stream =
        new Observable<dynamic>(_getStream().asBroadcastStream()).ofType(kInt);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.ofType.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<dynamic>(new ErrorStream<num>(new Exception()))
            .ofType(kNum);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.ofType.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = new Observable<int>.just(1).ofType(kInt);

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
