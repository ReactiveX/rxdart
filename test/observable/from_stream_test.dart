import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.fromStream', () async {
    const int value = 1;

    Stream<int> observable = new Observable<int>.fromStream(
        new Stream<int>.fromIterable(<int>[value]));

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
      expect(observable is Observable, isTrue);
    }, count: 1));
  });
}
