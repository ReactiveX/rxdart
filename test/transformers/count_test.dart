import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.count.noPredicate', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3];
    int count = 0;

    new Observable<String>(
            new Stream<String>.fromIterable(<String>['a', 'b', 'c']))
        .count()
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.count.withPredicate', () async {
    new Observable<String>(
            new Stream<String>.fromIterable(<String>['a', 'b', 'c']))
        .count((String char) => char == 'b')
        .listen(expectAsync1((int result) {
      expect(1, result);
    }));
  });

  test('rx.Observable.count.asBroadcastStream', () async {
    Stream<int> stream = new Observable<String>(
            new Stream<String>.fromIterable(<String>['a', 'b', 'c'])
                .asBroadcastStream())
        .count();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.count.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception())).count();

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.count.error.predicate', () async {
    Stream<int> observableWithError =
        new Observable<ErrorComparator>.fromIterable(
                <ErrorComparator>[new ErrorComparator(), new ErrorComparator()])
            .count((ErrorComparator error) => throw new Exception());

    observableWithError.listen((_) {}, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}

class ErrorComparator implements Comparable<ErrorComparator> {
  @override
  int compareTo(ErrorComparator other) {
    throw new Exception();
  }
}
