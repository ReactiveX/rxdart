import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.fromIterable', () async {
    const int value = 1;

    Stream<int> observable = new Observable<int>.fromIterable(<int>[value]);

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });
}
