import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.skipWhile', () async {
    Stream<int> observable = Observable<int>.fromIterable(<int>[1, 2, 3])
        .skipWhile((int value) => value < 3);

    observable.listen(expectAsync1((int actual) {
      expect(actual, 3);
    }, count: 1));
  });
}
