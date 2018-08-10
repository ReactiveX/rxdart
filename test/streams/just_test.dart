import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.just', () async {
    const int value = 1;

    Stream<int> observable = new Observable<int>.just(value);

    observable.listen(expectAsync1((int actual) {
      expect(actual, value);
    }, count: 1));
  });

  test('rx.Observable.just.doOnDone', () async {
    bool onDoneCalled = false;

    Stream<int> observable = new Observable<int>.just(1).doOnDone(() {
      onDoneCalled = true;
    });

    observable.listen((_) {
      //nothing
    });

    await new Future<int>.delayed(new Duration(milliseconds: 10));

    await expectLater(onDoneCalled, isTrue);
  });
}
