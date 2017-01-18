import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

void main() {
  test('rx.Observable.timeInterval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    int count = 0;

    rx.observable(_getStream())
        .interval(const Duration(milliseconds: 20))
        .timeInterval()
        .listen(expectAsync1((rx.TimeInterval<int> result) {
          expect(expectedOutput[count++], result.value);

          expect(result.interval >= 20000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.asBroadcastStream', () async {
    Stream<rx.TimeInterval<int>> observable = rx.observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20))
        .timeInterval();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.timeInterval.error.shouldThrow', () async {
   Stream<rx.TimeInterval<num>> observableWithError = rx.observable(getErroneousStream())
        .interval(const Duration(milliseconds: 20))
        .timeInterval();

     observableWithError.listen(null, onError: (dynamic e, dynamic s) {
       expect(e, isException);
     });
  });
}
