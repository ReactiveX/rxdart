import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.asyncMap', () async {
    final int expected = 1;

    Stream<int> observable = new Observable<int>.just(expected)
        .asyncMap((int value) => new Future<int>.value(value));

    observable.listen(expectAsync1((int actual) {
      expect(actual, expected);
    }));
  });
}
