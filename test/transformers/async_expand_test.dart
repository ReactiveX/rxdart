import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.asyncExpand', () async {
    final List<int> expected = <int>[1, 2, 3];
    int count = 0;

    Stream<int> observable = new Observable<int>.fromIterable(expected)
        .asyncExpand(
            (int value) => new Observable<int>.fromIterable(<int>[value]));

    observable.listen(expectAsync1((int actual) {
      expect(actual, expected[count++]);
    }, count: expected.length));
  });
}
