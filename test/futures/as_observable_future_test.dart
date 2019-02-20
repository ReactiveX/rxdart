import 'dart:async';

import 'package:rxdart/src/futures/as_observable_future.dart';
import 'package:test/test.dart';

void main() {
  test('AsObservableFuture.asObservable', () async {
    final future = AsObservableFuture<int>(Future<int>.value(1));

    await expectLater(future.asObservable(), emits(1));
  });
}
