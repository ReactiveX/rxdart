import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.timeout', () async {
    StreamSubscription<int> subscription;

    Stream<int> observable = new Observable<int>.fromFuture(
            new Future<int>.delayed(new Duration(milliseconds: 30), () => 1))
        .timeout(new Duration(milliseconds: 1));

    subscription = observable.listen((_) {},
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e is TimeoutException, isTrue);
          subscription.cancel();
        }, count: 1));
  });
}
