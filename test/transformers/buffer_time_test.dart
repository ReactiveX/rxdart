import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => new Observable<int>((int n) async* {
      int k = 0;

      while (k < n) {
        await new Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.bufferTime', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .bufferTime(const Duration(milliseconds: 220))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferTime.asBuffer', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .buffer(onTime(const Duration(milliseconds: 220)))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferTime.shouldClose', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .bufferTime(const Duration(seconds: 3))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput);
        }, count: 1));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferTime.shouldClose.asBuffer', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .buffer(onTime(const Duration(seconds: 3)))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput);
        }, count: 1));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferTime.reusable', () async {
    final StreamTransformer<int, List<int>> transformer =
        new BufferStreamTransformer<int>(
            onTime(const Duration(milliseconds: 220)));
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int countA = 0, countB = 0;

    Stream<List<int>> streamA = getStream(4).transform(transformer);

    streamA.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    Stream<List<int>> streamB = getStream(4).transform(transformer);

    streamB.listen(expectAsync1((List<int> result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  });

  test('rx.Observable.bufferTime.asBroadcastStream', () async {
    final Stream<List<int>> stream = getStream(4)
        .asBroadcastStream()
        .bufferTime(const Duration(milliseconds: 220));

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTime.asBroadcastStream.asBuffer', () async {
    final Stream<List<int>> stream = getStream(4)
        .asBroadcastStream()
        .buffer(onTime(const Duration(milliseconds: 220)));

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTime.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .bufferTime(const Duration(milliseconds: 220));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTime.error.shouldThrowA.asBuffer', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .buffer(onTime(const Duration(milliseconds: 220)));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTime.error.shouldThrowB', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .bufferTime(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferTime.error.shouldThrowB.asBuffer', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .buffer(onTime(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
