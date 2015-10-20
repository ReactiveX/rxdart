@test.TestOn("browser")

library buffer_when_test;

import 'dart:async';
import "package:test/test.dart" as test;
import 'package:guinness/guinness_html.dart';
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
    guinnessEnableHtmlMatchers();
    
    Rx.Observable observable;
    
    beforeEach(() {
      observable = new Rx.Observable.from([1, 2, 3]);
    });
    
    describe("Rx.Observable.from", () {
      it("creates an Observable from a List", () {
        return testObservable(new Rx.Observable.from([1, 2, 3]),
          expectation: (values) => expect(values).toEqual([1, 2, 3]));
      });
    });
    
    describe("Rx.Observable.range", () {
      it("creates an Observable from a range", () {
        return testObservable(new Rx.Observable.range(0, 3),
          expectation: (values) => expect(values).toEqual([0, 1, 2]));
      });
    });
    
    describe("Rx.Observable.fromFuture", () {
      it("creates an Observable from a Future", () {
        return testObservable(new Rx.Observable.fromFuture(new Future<int>.value(0)),
          expectation: (values) => expect(values).toEqual([0]));
      });
    });
    
    describe("Rx.Observable.bufferWithCount", () {
      it("buffers values and creates Lists to contain the values", () {
        return testObservable(observable.bufferWithCount(2),
          expectation: (values) => expect(values).toEqual([[1, 2], [3]]));
      });
    });
    
    describe("Rx.Observable.debounce", () {
      it("debounces an Observable using Duration", () {
        return testObservable(observable.debounce(const Duration(seconds: 1)),
          expectation: (values) => expect(values).toEqual([3]));
      });
    });
    
    describe("Rx.Observable.flatMap", () {
      it("transforms values and returns a new Observable", () {
        return testObservable(observable.flatMap((int value) => new Rx.Observable.from([value * 2])),
          expectation: (values) => expect(values).toEqual([2, 4, 6]));
      });
    });
    
    describe("Rx.Observable.flatMapLatest", () {
      it("transforms values and returns a new Observable", () {
        return testObservable(observable.flatMapLatest((int value) => new Rx.Observable.from([value * 2])),
          expectation: (values) => expect(values).toEqual([2, 4, 6]));
      });
    });
  });
}