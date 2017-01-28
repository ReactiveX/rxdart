import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.distinct', () async {
    final int expected = 1;

    Stream<int> observable =
        new Observable<int>.fromIterable(<int>[expected, expected]).distinct();

    observable.listen(expectAsync1((int actual) {
      expect(actual, expected);
    }));
  });
}
