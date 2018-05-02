import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.where', () async {
    Stream<int> observable = new Observable<int>.fromIterable(<int>[1, 2, 3])
        .where((int value) => value < 2);

    observable.listen(expectAsync1((int actual) {
      expect(actual, 1);
    }, count: 1));
  });
}
