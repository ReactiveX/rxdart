import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Observable<int> getStream(int n) => Observable<int>((int n) async* {
      var k = 0;

      while (k < n) {
        await Future<Null>.delayed(const Duration(milliseconds: 100));

        yield k++;
      }
    }(n));

void main() {
  test('rx.Observable.windowTime', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .windowTime(const Duration(milliseconds: 220))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowTime.asWindow', () async {
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var count = 0;

    getStream(4)
        .window(onTime(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .listen(expectAsync1((result) {
          // test to see if the combined output matches
          expect(result, expectedOutput[count++]);
        }, count: 2));
  });

  test('rx.Observable.windowTime.shouldClose', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .windowTime(const Duration(seconds: 3))
        .asyncMap((s) => s.toList())
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

  test('rx.Observable.windowTime.shouldClose.asWindow', () async {
    const expectedOutput = [0, 1, 2, 3];
    final controller = StreamController<int>();

    Observable(controller.stream)
        .window(onTime(const Duration(seconds: 3)))
        .asyncMap((s) => s.toList())
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

  test('rx.Observable.windowTime.reusable', () async {
    final transformer =
        WindowStreamTransformer<int>(onTime(const Duration(milliseconds: 220)));
    const expectedOutput = [
      [0, 1],
      [2, 3]
    ];
    var countA = 0, countB = 0;

    final streamA =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamA.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countA++]);
    }, count: 2));

    final streamB =
        getStream(4).transform(transformer).asyncMap((s) => s.toList());

    streamB.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[countB++]);
    }, count: 2));
  });

  test('rx.Observable.windowTime.asBroadcastStream', () async {
    final stream = getStream(4)
        .windowTime(const Duration(milliseconds: 220))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowTime.asBroadcastStream.asWindow', () async {
    final stream = getStream(4)
        .window(onTime(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList())
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen(expectAsync1((_) {}, count: 2));
    stream.listen(expectAsync1((_) {}, count: 2));
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.windowTime.error.shouldThrowA', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .windowTime(const Duration(milliseconds: 220))
        .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowTime.error.shouldThrowA.asWindow', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()))
        .window(onTime(const Duration(milliseconds: 220)))
        .asyncMap((s) => s.toList());

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.windowTime.error.shouldThrowB', () {
    Observable.fromIterable(const [1, 2, 3, 4]).windowTime(null).listen(null,
        onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });

  test('rx.Observable.windowTime.error.shouldThrowB.asWindow', () {
    Observable.fromIterable(const [1, 2, 3, 4])
        .window(onTime(null))
        .listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
