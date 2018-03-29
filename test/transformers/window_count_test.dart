import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.windowCount.noSkip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;

    Stream<Stream<int>> stream =
        new Observable<int>.fromIterable(<int>[1, 2, 3, 4]).windowCount(2);

    stream.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 2));
  });

  test('rx.Observable.windowCount.reusable', () async {
    final WindowCountStreamTransformer<int> transformer =
        new WindowCountStreamTransformer<int>(2);
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int countA = 0, countB = 0;

    Stream<Stream<int>> streamA =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .transform(transformer);

    streamA.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[countA++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 2));

    Stream<Stream<int>> streamB =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .transform(transformer);

    streamB.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[countB++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 2));
  });

  test('rx.Observable.windowCount.skip', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[2, 3],
      const <int>[3, 4],
      const <int>[4]
    ];
    int count = 0;

    Stream<Stream<int>> stream =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .windowCount(2, 1);

    stream.listen(expectAsync1((Stream<int> result) {
      // test to see if the combined output matches
      List<int> expected = expectedOutput[count++];
      int innerCount = 0;

      result.listen(expectAsync1((int value) {
        expect(expected[innerCount++], value);
      }, count: expected.length));
    }, count: 4));
  });

  test('rx.Observable.windowCount.asBroadcastStream', () async {
    Stream<Stream<int>> stream = new Observable<int>(
            new Stream<int>.fromIterable(<int>[1, 2, 3, 4]).asBroadcastStream())
        .windowCount(2);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowCount.error.shouldThrowA', () async {
    Stream<Stream<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .windowCount(2);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowCount.skip.shouldThrowB', () {
    expect(
        () => new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
            .windowCount(2, 100),
        throwsArgumentError);
  });

  test('rx.Observable.windowCount.error.shouldThrowC', () {
    expect(() => new Observable<num>.just(1).windowCount(null),
        throwsArgumentError);
  });

  test('rx.Observable.windowCount.pause.resume', () async {
    StreamSubscription<Stream<int>> subscription;
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[1, 2],
      const <int>[3, 4]
    ];
    int count = 0;
    Stream<Stream<int>> stream =
        new Observable<int>(new Stream<int>.fromIterable(<int>[1, 2, 3, 4]))
            .windowCount(2);

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
