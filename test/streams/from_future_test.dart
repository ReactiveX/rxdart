import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.fromFuture', () async {
    const value = 1;

    final observable = Observable.fromFuture(Future.value(value));

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });
}
