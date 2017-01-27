import '../test_utils.dart';
import 'dart:async';

import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.bufferWithCount.noSkip', () async {
    new FakeAsync().run((FakeAsync fakeAsync) {
      const List<List<int>> expectedOutput = const <List<int>>[
        const <int>[1, 2],
        const <int>[3, 4]
      ];
      int count = 0;

      Stream<List<int>> stream = observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4])).bufferWithCount(2);

      stream.listen(expectAsync1((List<int> result) {
        // test to see if the combined output matches
        expect(expectedOutput[count][0], result[0]);
        expect(expectedOutput[count][1], result[1]);
        count++;
      }, count: 2));

      fakeAsync.elapse(new Duration(minutes: 1));
    });
  });

  test('rx.Observable.bufferWithCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<List<int>> stream = observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4])).bufferWithCount(2, 1);

    stream.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count].length, result.length);
      expect(expectedOutput[count][0], result[0]);
      if (expectedOutput[count].length > 1)
        expect(expectedOutput[count][1], result[1]);
      count++;
    }, count: 4));
  });

  test('rx.Observable.bufferWithCount.asBroadcastStream', () async {
    Stream<List<int>> stream =
        observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream()).bufferWithCount(2);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.bufferWithCount.error.shouldThrow', () async {
    Stream<List<num>> observableWithError =
        observable(getErroneousStream()).bufferWithCount(2);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.bufferWithCount.skip.shouldThrow', () async {
    try {
      observable(new Stream<int>.fromIterable(<int>[1, 2, 3, 4])).bufferWithCount(2, 100);
    } catch (e) {
      expect(e, isArgumentError);
    }
  });
}
