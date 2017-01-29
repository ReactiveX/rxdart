import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.timeout', () async {
    Stream<int> observable = new Observable<int>.fromFuture(
            new Future<int>.delayed(new Duration(days: 1), () => 1))
        .timeout(new Duration(milliseconds: 1));

    observable.listen((_) {},
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e is TimeoutException, isTrue);
        }, count: 1));
  });
}
