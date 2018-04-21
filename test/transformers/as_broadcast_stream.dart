import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.asBroadcastStream', () async {
    Stream<int> observable = new Observable<int>.just(1).asBroadcastStream();

    await expectLater(observable.isBroadcast, isTrue);
  });
}
