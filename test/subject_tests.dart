library test.subject;

import 'dart:async';
import 'package:test/test.dart' as test;
import 'package:rxdart/rxdart.dart' as Rx;

import 'test_utils.dart';

void main() {
  test.test('Rx.ReplaySubject', () async {
    final Rx.ReplaySubject<int> S = new Rx.ReplaySubject();
    
    S.onNext(1);
    S.onNext(2);
    S.onNext(3);
    S.onCompleted();
    
    new Future.delayed(const Duration(seconds: 1), () async {
      test.expect(await testObservable(S), [1, 2, 3]);
    });
  });
}