import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

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
    rx
        .observable(_getStream())
        .ofType((event) => event as Map<String, int>)
        .listen(expectAsync1((Map<String, int> result) {
          expect(result, isMap);
        }, count: 1));
  });

  test('rx.Observable.ofType.polymorphism', () async {
    rx
        .observable(_getStream())
        .ofType((event) => event as num)
        .listen(expectAsync1((num result) {
          expect(result is num, true);
        }, count: 2));
  });

  test('rx.Observable.ofType.asBroadcastStream', () async {
    Stream<int> observable = rx
        .observable(_getStream().asBroadcastStream())
        .ofType((event) => event as int);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.ofType.error.shouldThrow', () async {
    Stream<num> observableWithError =
        rx.observable(getErroneousStream()).ofType((event) => event as num);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
