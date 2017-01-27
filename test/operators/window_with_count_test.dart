import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.windowWithCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<Stream<int>> stream = observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4])).windowWithCount(2);

    stream.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 2));
  });

  test('rx.Observable.windowWithCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<Stream<int>> stream = observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4])).windowWithCount(2, 1);

    stream.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 4));
  });

  test('rx.Observable.windowWithCount.asBroadcastStream', () async {
    Stream<Stream<int>> stream =
        observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream()).windowWithCount(2);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.windowWithCount.error.shouldThrow', () async {
    Stream<Stream<num>> observableWithError =
        observable(getErroneousStream()).windowWithCount(2);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.windowWithCount.pause.resume', () async {
    StreamSubscription<Stream<int>> subscription;
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;
    Stream<Stream<int>> stream = observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4])).windowWithCount(2);

    subscription = stream.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);

        if (count == expectedOutput.length) {
          subscription.cancel();
        }
      }, count: expected.length));
    }, count: 2));

    subscription.pause();
    subscription.resume();
  });
}
