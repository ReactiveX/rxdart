import 'dart:async';

import 'package:test/test.dart';

void main() {
  test('rx.Observable.timeout', () async {
    StreamSubscription<int> subscription;

    Stream<int> observable = Stream<int>.fromFuture(
            Future<int>.delayed(Duration(milliseconds: 30), () => 1))
        .timeout(Duration(milliseconds: 1));

    subscription = observable.listen((_) {},
        onError: expectAsync2((TimeoutException e, StackTrace s) {
          expect(e is TimeoutException, isTrue);
          subscription.cancel();
        }, count: 1));
  });
}
