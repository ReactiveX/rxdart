import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

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
    observable(_getStream())
        .ofType(new TypeToken<Map<String, int>>())
        .listen(expectAsync1((Map<String, int> result) {
          expect(result, isMap);
        }, count: 1));
  });

  test('rx.Observable.ofType.polymorphism', () async {
    observable(_getStream()).ofType(kNum).listen(expectAsync1((num result) {
          expect(result is num, true);
        }, count: 2));
  });

  test('rx.Observable.ofType.asBroadcastStream', () async {
    Stream<int> stream =
        observable(_getStream().asBroadcastStream()).ofType(kInt);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.ofType.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).ofType(kNum);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
