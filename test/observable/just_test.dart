import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

void main() {
  test('rx.Observable.just', () async {
    const int value = 1;

    Stream<int> observable = new rx.Observable<int>.just(value);

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });
}
