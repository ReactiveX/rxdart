import 'dart:async';

import 'package:rxdart/src/streams/error.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('ErrorStream', () async {
    bool onDataCalled = false;
    Stream<int> stream = new ErrorStream<int>(new Exception());

    stream.listen(
        expectAsync1((int actual) {
          onDataCalled = true;
        }, count: 0),
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e, isException);
        }, count: 1),
        onDone: expectAsync0(() {
          expect(true, true);
          expect(onDataCalled, isFalse);
        }, count: 1));
  });

  test('rx.Observable.error', () async {
    bool onDataCalled = false;
    Observable<int> observable = new Observable<int>.error(new Exception());

    observable.listen(
        expectAsync1((int actual) {
          onDataCalled = true;
        }, count: 0),
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e, isException);
        }, count: 1),
        onDone: expectAsync0(() {
          expect(true, true);
          expect(onDataCalled, isFalse);
        }, count: 1));
  });
}
