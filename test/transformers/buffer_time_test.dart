import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => Observable<int>((int n) async* {
      var k = 0;

      while (k < n) {
        await Future<void>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.bufferTime', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .bufferTime(const Duration(milliseconds: 220))
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferTime.asBuffer', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .buffer(onTime(const Duration(milliseconds: 220)))
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.bufferTime.shouldClose', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .bufferTime(const Duration(seconds: 3))
        .listen(expectAsync1((result) {
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
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .buffer(onTime(const Duration(seconds: 3)))
        .listen(expectAsync1((result) {
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
    final transformer =
        BufferStreamTransformer<int>(onTime(const Duration(milliseconds: 220)));
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var countA = 0, countB = 0;

    final streamA = getStream(4).transform(transformer);

    streamA.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    final streamB = getStream(4).transform(transformer);

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  });

  test('rx.Observable.bufferTime.asBroadcastStream', () async {
    final stream = getStream(4)
        .asBroadcastStream()
        .bufferTime(const Duration(milliseconds: 220));

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTime.asBroadcastStream.asBuffer', () async {
    final stream = getStream(4)
        .asBroadcastStream()
        .buffer(onTime(const Duration(milliseconds: 220)));

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.bufferTime.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .bufferTime(const Duration(milliseconds: 220));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTime.error.shouldThrowA.asBuffer', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .buffer(onTime(const Duration(milliseconds: 220)));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.bufferTime.error.shouldThrowB', () {
    Observable.fromIterable(const [1, 2, 3, 4]).bufferTime(null).listen(null,
        onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.bufferTime.error.shouldThrowB.asBuffer', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .buffer(onTime(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
