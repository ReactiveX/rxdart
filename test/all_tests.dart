@test.TestOn("browser")

library buffer_when_test;

import 'dart:async';
import "package:test/test.dart" as test;
import 'package:rxdart/rxdart.dart' as Rx;

Future<List> testObservable(Rx.Observable observable) {
  final Completer<List> C = new Completer();
  final List results = [];

  observable.subscribe(
      (value) => results.add(value),
      onError: (error) => print(error),
      onCompleted: () => C.complete(results)
  );

  return C.future;
}

void main() {
  test.test('Rx.Observable.from', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3])
    ), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.range', () async {
    test.expect(await testObservable(
        new Rx.Observable.range(0, 3)
    ), [0, 1, 2]);
  });
  
  test.test('Rx.Observable.fromFuture', () async {
    test.expect(await testObservable(
        new Rx.Observable.fromFuture(new Future<int>.value(0))
    ), [0]);
  });
  
  test.test('Rx.Observable.combineLatest', () async {
    test.expect(await testObservable(
        new Rx.Observable.combineLatest(new Rx.Observable.from([1, 2, 3]), new Rx.Observable.from([4, 5, 6]))
    ), [[1, 4], [2, 4], [2, 5], [3, 5], [3, 6]]);
  });
  
  test.test('Rx.Observable.bufferWithCount', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).bufferWithCount(2)
    ), [[1, 2], [3]]);
  });
  
  test.test('Rx.Observable.debounce', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).debounce(const Duration(seconds: 1))
    ), [3]);
  });
  
  test.test('Rx.Observable.delay', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).delay(const Duration(seconds: 1))
    ), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.delayWithDateTime', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).delayWithDateTime(new DateTime.now().add(const Duration(seconds: 1)))
    ), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.delayWithDurationSelector', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).delayWithDurationSelector((int i) => new Rx.Observable.timer(const Duration(seconds: 1)))
    ), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.delayWithSubscriptionDelay', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).delayWithSubscriptionDelay(new Rx.Observable.timer(const Duration(milliseconds: 500)), (int i) => new Rx.Observable.timer(const Duration(seconds: 1)))
    ), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.flatMap', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).flatMap((int value) => new Rx.Observable.from([value * 2]))
    ), [2, 4, 6]);
  });
  
  test.test('Rx.Observable.flatMapLatest', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).flatMapLatest((int value) => new Rx.Observable.from([value * 2]))
    ), [2, 4, 6]);
  });
  
  test.test('Rx.Observable.toList', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).toList()
    ), [[1, 2, 3]]);
  });
  
  test.test('Rx.Observable.pluck', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([{'a': {'b': {'c': 'd'}}}]).pluck(['a', 'b', 'c'])
    ), ['d']);
  });
  
  test.test('Rx.Observable.windowWithCount', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).windowWithCount(2).flatMap((Rx.Observable<int> o) => o.toList())
    ), [[1, 2], [3]]);
  });
}