import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() => new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4]);

void main() {
  test('rx.Observable.interval', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3, 4];
    int count = 0, lastInterval = -1;
    Stopwatch stopwatch = new Stopwatch()..start();

    observable(_getStream()).interval(const Duration(milliseconds: 1)).listen(
        expectAsync1((int result) {
          expect(expectedOutput[count++], result);

          if (lastInterval != -1)
            expect(stopwatch.elapsedMilliseconds - lastInterval >= 1, true);

          lastInterval = stopwatch.elapsedMilliseconds;
        }, count: expectedOutput.length),
        onDone: stopwatch.stop);
  });

  test('rx.Observable.interval.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream())
        .interval(const Duration(milliseconds: 20));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.interval.error.shouldThrow', () async {
    Stream<num> observableWithError = observable(getErroneousStream())
        .interval(const Duration(milliseconds: 20));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
