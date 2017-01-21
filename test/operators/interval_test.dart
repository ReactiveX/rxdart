import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4]);

void main() {
  test('rx.Observable.interval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4];
    int count = 0, lastInterval = -1;
    Stopwatch stopwatch = new Stopwatch()..start();

    rx
        .observable(_getStream())
        .interval(const Duration(milliseconds: 20))
        .listen(
            expectAsync1((int result) {
              expect(expectedOutput[count++], result);

              if (lastInterval != -1)
                expect(
                    stopwatch.elapsedMilliseconds - lastInterval >= 20, true);

              lastInterval = stopwatch.elapsedMilliseconds;
            }, count: expectedOutput.length),
            onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.asBroadcastStream', () async {
    Stream<int> observable = rx
        .observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20));

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.interval.error.shouldThrow', () async {
    Stream<num> observableWithError = rx
        .observable(getErroneousStream())
        .interval(const Duration(milliseconds: 20));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
