import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.asyncMap', () async {
    const expected = 1;

    final observable = new Observable.just(expected)
        .asyncMap((value) => new Future.value(value));

    observable.listen(expectAsync1((actual) {
      expect(actual, expected);
    }));
  });
}
