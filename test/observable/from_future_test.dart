import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.fromFuture', () async {
    const int value = 1;

    Stream<int> observable =
        new Observable<int>.fromFuture(new Future<int>.value(value));

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });
}
