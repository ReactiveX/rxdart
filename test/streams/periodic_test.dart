import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

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
