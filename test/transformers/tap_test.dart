import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.doOnData', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    List<int> actualOutput = <int>[];
    int count = 0;

    new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
        .doOnData((int value) => actualOutput.add(value))
        .listen(expectAsync1((_) {
          expect(actualOutput[count], expectedOutput[count++]);
        }, count: 4));
  });

  test('rx.Observable.doOnData.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .doOnData((_) {});

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.doOnData.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(getErroneousStream()).doOnData((_) {});

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
