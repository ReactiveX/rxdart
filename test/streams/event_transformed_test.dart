import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.eventTransformed', () async {
    Stream<int> source = new Observable<int>.just(1);
    Stream<int> observable = new Observable<int>.eventTransformed(
        source, (EventSink<int> sink) => sink);

    await expectLater(observable is Observable, isTrue);
  });
}
