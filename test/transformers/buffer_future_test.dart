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
  test('rx.Observable.bufferFuture', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .bufferFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferFuture.asBuffer', () async {
    const List<List<int>> expectedOutput = const <List<int>>[
      const <int>[0, 1],
      const <int>[2, 3]
    ];
    int count = 0;

    getStream(4)
        .buffer(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))))
        .listen(expectAsync1((List<int> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferFuture.sampleBeforeEvent.shouldEmit', () async {
    const List<List<String>> expectedOutput = const <List<String>>[
      const <String>[],
      const <String>[],
      const <String>[],
      const <String>[],
      const <String>['done']
    ];
    int count = 0;

    new Observable<String>.fromFuture(
            new Future<Null>.delayed(const Duration(milliseconds: 200))
                .then((_) => 'done'))
        .bufferFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 40)))
        .listen(expectAsync1((List<String> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 5));
  });

  test('rx.Observable.bufferFuture.sampleBeforeEvent.shouldEmit.asBuffer',
      () async {
    const List<List<String>> expectedOutput = const <List<String>>[
      const <String>[],
      const <String>[],
      const <String>[],
      const <String>[],
      const <String>['done']
    ];
    int count = 0;

    new Observable<String>.fromFuture(
            new Future<Null>.delayed(const Duration(milliseconds: 200))
                .then((_) => 'done'))
        .buffer(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 40))))
        .listen(expectAsync1((List<String> result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 5));
  });

  test('rx.Observable.bufferFuture.shouldClose', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .bufferFuture(
            () => new Future<Null>.delayed(const Duration(seconds: 3)))
        .listen(
            expectAsync1((List<int> result) => expect(result, expectedOutput),
                count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferFuture.shouldClose.asBuffer', () async {
    const List<int> expectedOutput = const <int>[0, 1, 2, 3];
    final StreamController<int> controller = new StreamController<int>();

    new Observable<int>(controller.stream)
        .buffer(onFuture(
            () => new Future<Null>.delayed(const Duration(seconds: 3))))
        .listen(
            expectAsync1((List<int> result) => expect(result, expectedOutput),
                count: 1),
            onDone: expectAsync0(() => expect(true, isTrue)));

    controller.add(0);
    controller.add(1);
    controller.add(2);
    controller.add(3);

    scheduleMicrotask(controller.close);
  });

  test('rx.Observable.bufferFuture.reusable', () async {
    final StreamTransformer<int, List<int>> transformer =
        new BufferStreamTransformer<int>(onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))));
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

  test('rx.Observable.bufferFuture.asBroadcastStream', () async {
    final Stream<List<int>> stream = getStream(4)
        .asBroadcastStream()
        .bufferFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)));

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferFuture.asBroadcastStream.asBuffer', () async {
    final Stream<List<int>> stream = getStream(4).asBroadcastStream().buffer(
        onFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220))));

    // listen twice on same stream
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    stream.listen(expectAsync1((List<int> result) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferFuture.error.shouldThrowA', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception())).bufferFuture(
            () => new Future<Null>.delayed(const Duration(milliseconds: 220)));

    observableWithError.listen(null,
        onError: expectAsync2((Object e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferFuture.error.shouldThrowA.asBuffer', () async {
    Stream<List<num>> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception())).buffer(
            onFuture(() =>
                new Future<Null>.delayed(const Duration(milliseconds: 220))));

    observableWithError.listen(null,
        onError: expectAsync2((Object e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferFuture.error.shouldThrowB', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .bufferFuture<Null>(null)
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferFuture.error.shouldThrowB.asFuture', () {
    new Observable<int>.fromIterable(<int>[1, 2, 3, 4])
        .buffer(onFuture<int, List<int>, Null>(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
