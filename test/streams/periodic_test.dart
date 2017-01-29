import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.periodic', () async {
    const int value = 1;

    Stream<int> observable = new Observable<int>.periodic(
        new Duration(milliseconds: 1), (int count) => value).take(1);

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });
}
