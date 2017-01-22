import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.asBroadcastStream', () async {
    Stream<int> observable = new Observable<int>.just(1).asBroadcastStream();

    expect(observable is Observable, isTrue);
    expect(observable.isBroadcast, isTrue);
  });
}
