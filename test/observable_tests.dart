library test.observable;

import 'dart:async';
import 'package:test/test.dart' as test;
import 'package:rxdart/rxdart.dart' as Rx;

import 'test_utils.dart';

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
  
  test.test('Rx.Observable.fromStream', () async {
    final StreamController<int> C = new StreamController<int>();
    
    C.add(1);
    C.add(2);
    C.add(3);
    C.close();
    
    test.expect(await testObservable(
        new Rx.Observable.fromStream(C.stream)
    ), [1, 2, 3]);
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
  
  test.test('Rx.Observable.delayUntil', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).delayUntil(new DateTime.now().add(const Duration(seconds: 1)))
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
  
  test.test('Rx.Observable.throttle', () async {
    final List<Map<String, int>> times = <Map<String, int>>[
      { 'value': 0, 'time': 100 },
      { 'value': 1, 'time': 600 },
      { 'value': 2, 'time': 400 },
      { 'value': 3, 'time': 900 },
      { 'value': 4, 'time': 200 }
    ];
    
    test.expect(await testObservable(
        new Rx.Observable<Map<String, int>>.from(times)
          .flatMap((Map<String, int> x) => new Rx.Observable<int>.of(x['value']).delay(new Duration(milliseconds: x['time'])))
          .throttle(const Duration(milliseconds: 300))
    ), [0, 2, 3]);
  });
  
  test.test('Rx.Observable.toList', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).toList()
    ), [[1, 2, 3]]);
  });
  
  test.test('Rx.Observable.toStream', () async {
    final Rx.Subject<int> O = new Rx.Subject<int>();
    final Stream<int> S = O.toStream();
    
    O.onNext(1);
    O.onNext(2);
    O.onNext(3);
    O.onCompleted();
    
    test.expect(await S.toList(), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.partition', () async {
    test.expect(await testObservable(
        new Rx.Observable.range(0, 10).partition((int x) => x % 2 == 0).first // evens
    ), [0, 2, 4, 6, 8]);
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