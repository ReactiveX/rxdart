@test.TestOn("browser")

library buffer_when_test;

import 'dart:async';
import "package:test/test.dart" as test;
import 'package:guinness/guinness_html.dart' as guinness;
import 'package:rxdart/rxdart.dart' as Rx;

Future testObservable(Rx.Observable observable, {expectation(List values)}) {
  final Completer C = new Completer();
  final List results = [];

  observable.subscribe(
      (value) => results.add(value),
      onError: (error) => print(error),
      onCompleted: () {
        expectation(results);
        
        C.complete();
      }
  );

  return C.future;
}

void main() {
  test.test('run all', () {
    guinness.guinnessEnableHtmlMatchers();
    
    Rx.Observable observable;
    
    guinness.beforeEach(() {
      observable = new Rx.Observable.from([1, 2, 3]);
    });
    
    guinness.describe("Rx.Observable.from", () {
      guinness.it("creates an Observable from a List", () {
        return testObservable(new Rx.Observable.from([1, 2, 3]),
          expectation: (values) => guinness.expect(values).toEqual([1, 2, 3]));
      });
    });
    
    guinness.describe("Rx.Observable.range", () {
      guinness.it("creates an Observable from a range", () {
        return testObservable(new Rx.Observable.range(0, 3),
          expectation: (values) => guinness.expect(values).toEqual([0, 1, 2]));
      });
    });
    
    guinness.describe("Rx.Observable.fromFuture", () {
      guinness.it("creates an Observable from a Future", () {
        return testObservable(new Rx.Observable.fromFuture(new Future<int>.value(0)),
          expectation: (values) => guinness.expect(values).toEqual([0]));
      });
    });
    
    guinness.describe("Rx.Observable.combineLatest", () {
      guinness.it("creates an Observable combining other Observables", () {
        return testObservable(new Rx.Observable.combineLatest(new Rx.Observable.from([1, 2, 3]), new Rx.Observable.from([4, 5, 6])),
          expectation: (values) => guinness.expect(values).toEqual([[1, 4], [2, 4], [2, 5], [3, 5], [3, 6]]));
      });
    });
    
    guinness.describe("Rx.Observable.bufferWithCount", () {
      guinness.it("buffers values and creates Lists to contain the values", () {
        return testObservable(observable.bufferWithCount(2),
          expectation: (values) => guinness.expect(values).toEqual([[1, 2], [3]]));
      });
    });
    
    guinness.describe("Rx.Observable.debounce", () {
      guinness.it("debounces an Observable using Duration", () {
        return testObservable(observable.debounce(const Duration(seconds: 1)),
          expectation: (values) => guinness.expect(values).toEqual([3]));
      });
    });
    
    guinness.describe("Rx.Observable.flatMap", () {
      guinness.it("transforms values and returns a new Observable", () {
        return testObservable(observable.flatMap((int value) => new Rx.Observable.from([value * 2])),
          expectation: (values) => guinness.expect(values).toEqual([2, 4, 6]));
      });
    });
    
    guinness.describe("Rx.Observable.flatMapLatest", () {
      guinness.it("transforms values and returns a new Observable", () {
        return testObservable(observable.flatMapLatest((int value) => new Rx.Observable.from([value * 2])),
          expectation: (values) => guinness.expect(values).toEqual([2, 4, 6]));
      });
    });
  });
}