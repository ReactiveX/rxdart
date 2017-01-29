import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.expand', () async {
    final List<int> expected = <int>[1, 2, 3];
    int count = 0;

    Stream<int> observable = new Observable<int>.fromIterable(expected)
        .expand((int value) => <int>[value]);

    observable.listen(expectAsync1((int actual) {
      expect(actual, expected[count++]);
    }, count: expected.length));
  });
}
