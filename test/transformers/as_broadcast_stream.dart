import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.asBroadcastStream', () async {
    Stream<int> observable = new Observable<int>.just(1).asBroadcastStream();

    await expect(observable.isBroadcast, isTrue);
  });
}
