import 'dart:async';

import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:test/test.dart';

void main() {
  test('AsObservableFuture.asObservable', () async {
    AsObservableFuture<int> future =
        new AsObservableFuture<int>(new Future<int>.value(1));

    await expectLater(future.asObservable(), emits(1));
  });
}
