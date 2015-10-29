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
  
  test.test('Rx.Observable.amb', () async {
    test.expect(await testObservable(
        new Rx.Observable.amb([
          new Future.delayed(const Duration(seconds: 2), () => 'after 2 seconds'),
          new Future.delayed(const Duration(seconds: 1), () => 'after 1 second'),
          new Rx.Observable.fromFuture(new Future.delayed(const Duration(milliseconds: 500), () => 'after 0.5 seconds'))
        ])
    ), ['after 0.5 seconds']);
  });
  
  test.test('Rx.Observable.switchCase', () async {
    test.expect(await testObservable(
        new Rx.Observable.switchCase(
          () => 'foo',
          {'foo': new Rx.Observable.just(1), 'bar': new Rx.Observable.just(2)},
          elseSource: new Rx.Observable.just(3)
        )
    ), [1]);
    
    test.expect(await testObservable(
        new Rx.Observable.switchCase(
          () => 'baz',
          {'foo': new Rx.Observable.just(1), 'bar': new Rx.Observable.just(2)},
          elseSource: new Rx.Observable.just(3)
        )
    ), [3]);
  });
  
  test.test('Rx.Observable.interval', () async {
    test.expect(await testObservable(
        new Rx.Observable<int>.interval(const Duration(milliseconds: 300)).take(3)
    ), [0, 1, 2]);
  });
  
  test.test('Rx.Observable.defer', () async {
    test.expect(await testObservable(
        new Rx.Observable.defer(() => new Rx.Observable.just(1))
    ), [1]);
  });
  
  test.test('Rx.Observable.range', () async {
    test.expect(await testObservable(
        new Rx.Observable.range(0, 3)
    ), [0, 1, 2]);
  });
  
  test.test('Rx.Observable.repeat', () async {
    test.expect(await testObservable(
        new Rx.Observable.repeat(1, 3)
    ), [1, 1, 1]);
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
        new Rx.Observable.combineLatest([new Rx.Observable.from([1, 2, 3]), new Rx.Observable.from([4, 5, 6])], (int a, int b) => a + b)
    ), [5, 6, 7, 8, 9]);
  });
  
  test.test('Rx.Observable.forkJoin', () async {
    test.expect(await testObservable(
        new Rx.Observable.forkJoin([new Rx.Observable.from([1, 2, 3]), new Rx.Observable.from([4, 5, 6]), new Future.value(10)], (int a, int b, int c) => a + b + c)
    ), [19]);
  });
  
  test.test('Rx.Observable.of', () async {
    test.expect(await testObservable(
        new Rx.Observable.of(<int>[1, 2, 3])
    ), [1, 2, 3]);
  });
  
  test.test('Rx.Observable.merge', () async {
    test.expect(await testObservable(
        new Rx.Observable.merge([new Rx.Observable.from([1, 2, 3]), new Rx.Observable.from([4, 5, 6])])
    ), [1, 4, 2, 5, 3, 6]);
  });
  
  test.test('Rx.Observable.retry', () async {
    test.expect(await testObservable(
        new Rx.Observable.interval(const Duration(milliseconds: 300)).flatMap((i) {
          if (i >= 2) return new Rx.Observable.throwError(new Error());
          
          return new Rx.Observable.just(i);
        }).retry().take(3)
    ), [0, 1, 0]);
  });
  
  test.test('Rx.Observable.retryWhen', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).selectMany((int i) {
          if (i == 2) return new Rx.Observable.throwError(new Error());
          
          return new Rx.Observable.just(i);
        }).retryWhen((errors) {
          return errors.delay(200);
        }).take(3)
    ), [1, 1, 1]);
  });
  
  test.test('Rx.Observable.ambSingle', () async {
    test.expect(await testObservable(
        new Rx.Observable.fromFuture(new Future.delayed(const Duration(seconds: 1), () => 'after 1 second'))
          .ambSingle(new Rx.Observable.fromFuture(new Future.delayed(const Duration(milliseconds: 500), () => 'after 0.5 seconds')))
    ), ['after 0.5 seconds']);
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
  
  test.test('Rx.Observable.distinct', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 1, 2]).distinct()
    ), [1, 2]);
    
    test.expect(await testObservable(
        new Rx.Observable<Map<String, int>>.from([{'value': 1}, {'value': 2}, {'value': 1}, {'value': 2}])
          .distinct(keySelector: (e) => e['value'])
          .map((e) => e['value'])
    ), [1, 2]);
    
    final DateTime a = new DateTime.fromMillisecondsSinceEpoch(1000);
    final DateTime b = new DateTime.fromMillisecondsSinceEpoch(2000);
    
    test.expect(await testObservable(
        new Rx.Observable<Map<String, DateTime>>.from([a, b, a, b])
          .distinct(compare: (DateTime a, DateTime b) => a.isAtSameMomentAs(b))
    ), [a, b]);
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
  
  test.test('Rx.Observable.filter', () async {
    test.expect(await testObservable(
        new Rx.Observable<int>.from([1, 2, 3]).filter((int value) => value == 2)
    ), [2]);
  });
  
  test.test('Rx.Observable.find', () async {
    test.expect(await testObservable(
        new Rx.Observable<int>.from([1, 2, 3]).filter((int value) => value == 2)
    ), [2]);
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
  
  test.test('Rx.Observable.take', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).take(2)
    ), [1, 2]);
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
          .flatMap((Map<String, int> x) => new Rx.Observable<int>.just(x['value']).delay(new Duration(milliseconds: x['time'])))
          .throttle(const Duration(milliseconds: 300))
    ), [0, 2, 3]);
  });
  
  test.test('Rx.Observable.timeInterval', () async {
    final List<Map<String, int>> times = <Map<String, int>>[
      { 'value': 0, 'time': 100 },
      { 'value': 1, 'time': 600 },
      { 'value': 2, 'time': 400 },
      { 'value': 3, 'time': 900 },
      { 'value': 4, 'time': 200 }
    ];
    
    test.expect(await testObservable(
        new Rx.Observable<Map<String, int>>.from(times)
          .flatMap((Map<String, int> x) => new Rx.Observable<int>.just(x['value']).delay(new Duration(milliseconds: x['time'])).timeInterval())
          .map((Rx.TimedEvent<int> v) => v.value)
          .take(3)
    ), [0, 4, 2]);
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
  
  test.test('Rx.Observable.tap', () async {
    final List<int> sideEffects = <int>[];
    
    test.expect(await testObservable(
        new Rx.Observable.just(1).tap((int i) => sideEffects.add(i))
    ), [1]);
    
    test.expect(sideEffects, [1]);
  });
  
  test.test('Rx.Observable.windowWithCount', () async {
    test.expect(await testObservable(
        new Rx.Observable.from([1, 2, 3]).windowWithCount(2).flatMap((Rx.Observable<int> o) => o.toList())
    ), [[1, 2], [3]]);
  });
  
  test.test('Rx.bypass', () async {
    final StreamController<int> C = new StreamController<int>();
    final Stream<int> stream = Rx.bypass(C.stream.map((int i) => 'from Dart: $i'), (Rx.Observable<String> target) => target.map((String i) => 'from Rx: $i'));
    
    C.add(1);
    C.add(2);
    C.add(3);
    C.close();
    
    test.expect(await stream.toList(), ['from Rx: from Dart: 1', 'from Rx: from Dart: 2', 'from Rx: from Dart: 3']);
  });
}