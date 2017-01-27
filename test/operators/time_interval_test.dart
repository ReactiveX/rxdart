import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() => new Stream<int>.fromIterable(
    <int>[0, 1, 2]);

void main() {
  test('rx.Observable.timeInterval', () async {
    const List<int> expectedOutput = const <int>[
      0,
      1,
      2
    ];
    int count = 0;

    observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval()
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(expectedOutput[count++], result.value);

          expect(result.interval >= 1000 /* microseconds! */, true);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.timeInterval.asBroadcastStream', () async {
    Stream<TimeInterval<int>> stream =
        observable(_getStream().asBroadcastStream())
            .interval(const Duration(milliseconds: 1))
            .timeInterval();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.timeInterval.error.shouldThrow', () async {
    Stream<TimeInterval<num>> observableWithError =
        observable(getErroneousStream())
            .interval(const Duration(milliseconds: 1))
            .timeInterval();

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.timeInterval.pause.resume', () async {
    StreamSubscription<TimeInterval<int>> subscription;
    const List<int> expectedOutput = const <int>[0, 1, 2];
    int count = 0;

    subscription = observable(_getStream())
        .interval(const Duration(milliseconds: 1))
        .timeInterval()
        .listen(expectAsync1((TimeInterval<int> result) {
          expect(result.value, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
