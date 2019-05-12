import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/src/subjects/publish_subject.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.partition', () async {
    final observables = Observable.fromIterable(<int>[1, 2, 3, 4, 5, 6])
        .partition((int value) => value % 2 == 0);
    final evens = observables[0];
    final odds = observables[1];

    var evensCount = 0;
    final evensExpected = <int>[2, 4, 6];
    evens.listen(
      expectAsync1(
        (int actual) {
          expect(actual, evensExpected[evensCount++]);
        },
        count: evensExpected.length,
      ),
    );

    var oddsCount = 0;
    final oddsExpected = <int>[1, 3, 5];
    odds.listen(
      expectAsync1(
        (int actual) {
          expect(actual, oddsExpected[oddsCount++]);
        },
        count: oddsExpected.length,
      ),
    );
  });

  test('rx.Observable.partition.broadcastStream', () async {
    //ignore: close_sinks
    final source = PublishSubject<int>();

    final observables = source.partition((int value) => value % 2 == 0);
    final evens = observables[0];
    final odds = observables[1];

    var evensCount = 0;
    final evensExpected = <int>[2, 4, 6];
    evens.listen(
      expectAsync1(
        (int actual) {
          expect(actual, evensExpected[evensCount++]);
        },
        count: evensExpected.length,
      ),
    );

    var oddsCount = 0;
    final oddsExpected = <int>[1, 3, 5];
    odds.listen(
      expectAsync1(
        (int actual) {
          expect(actual, oddsExpected[oddsCount++]);
        },
        count: oddsExpected.length,
      ),
    );

    await source.addStream(Stream.fromIterable(<int>[1, 2, 3, 4, 5, 6]));
  });
}
