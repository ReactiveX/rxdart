import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.takeWhile', () async {
    Stream<int> observable = Observable<int>.fromIterable(<int>[1, 2, 3])
        .takeWhile((int value) => value < 2);

    observable.listen(expectAsync1((int actual) {
      expect(actual, 1);
    }, count: 1));
  });
}
