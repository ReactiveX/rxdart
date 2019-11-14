import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.zip', () async {
    expect(
      Observable.zip<String, String>([
        Observable.fromIterable(["A1", "B1"]),
        Observable.fromIterable(["A2", "B2", "C2"]),
      ], (values) => values.first + values.last),
      emitsInOrder(<dynamic>["A1A2", "B1B2", emitsDone]),
    );
  });

  test('rx.Observable.zipList', () async {
    expect(
      Observable.zipList([
        Observable.fromIterable(["A1", "B1"]),
        Observable.fromIterable(["A2", "B2", "C2"]),
        Observable.fromIterable(["A3", "B3", "C3"]),
      ]),
      emitsInOrder(<dynamic>[
        ['A1', 'A2', 'A3'],
        ['B1', 'B2', 'B3'],
        emitsDone
      ]),
    );
  });

  test('rx.Observable.zipBasics', () async {
    const expectedOutput = [
      [0, 1, true],
      [1, 2, false],
      [2, 3, true],
      [3, 4, false]
    ];
    var count = 0;

    final testStream = StreamController<bool>()
      ..add(true)
      ..add(false)
      ..add(true)
      ..add(false)
      ..add(true)
      ..close(); // ignore: unawaited_futures

    final observable = Observable.zip3(
        Stream.periodic(const Duration(milliseconds: 1), (count) => count)
            .take(4),
        Stream.fromIterable(const [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        testStream.stream,
        (int a, int b, bool c) => [a, b, c]);

    observable.listen(expectAsync1((result) {
      // test to see if the combined output matches
      for (var i = 0, len = result.length; i < len; i++) {
        expect(result[i], expectedOutput[count][i]);
      }

      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.zipTwo', () async {
    const expected = [1, 2];

    // A purposely emits 2 items, b only 1
    final a = Observable.fromIterable(const [1, 2]), b = Observable.just(2);

    final observable =
        Observable.zip2(a, b, (int first, int second) => [first, second]);

    // Explicitly adding count: 1. It's important here, and tests the difference
    // between zip and combineLatest. If this was combineLatest, the count would
    // be two, and a second List<int> would be emitted.
    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }, count: 1));
  });

  test('rx.Observable.zip3', () async {
    // Verify the ability to pass through various types with safety
    const expected = [1, "2", 3.0];

    final a = Observable.just(1),
        b = Observable.just("2"),
        c = Observable.just(3.0);

    final observable = Observable.zip3(a, b, c,
        (int first, String second, double third) => [first, second, third]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip4', () async {
    const expected = [1, 2, 3, 4];

    final a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4);

    final observable = Observable.zip4(
        a,
        b,
        c,
        d,
        (int first, int second, int third, int fourth) =>
            [first, second, third, fourth]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip5', () async {
    const expected = [1, 2, 3, 4, 5];

    final a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5);

    final observable = Observable.zip5(
        a,
        b,
        c,
        d,
        e,
        (int first, int second, int third, int fourth, int fifth) =>
            [first, second, third, fourth, fifth]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip6', () async {
    const expected = [1, 2, 3, 4, 5, 6];

    final a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6);

    final observable = Observable.zip6(
        a,
        b,
        c,
        d,
        e,
        f,
        (int first, int second, int third, int fourth, int fifth, int sixth) =>
            [first, second, third, fourth, fifth, sixth]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip7', () async {
    const expected = [1, 2, 3, 4, 5, 6, 7];

    final a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6),
        g = Observable.just(7);

    final observable = Observable.zip7(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh) =>
            [first, second, third, fourth, fifth, sixth, seventh]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip8', () async {
    const expected = [1, 2, 3, 4, 5, 6, 7, 8];

    final a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6),
        g = Observable.just(7),
        h = Observable.just(8);

    Stream<List<int>> observable = Observable.zip8(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh, int eighth) =>
            [first, second, third, fourth, fifth, sixth, seventh, eighth]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip9', () async {
    const expected = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    final a = Observable.just(1),
        b = Observable.just(2),
        c = Observable.just(3),
        d = Observable.just(4),
        e = Observable.just(5),
        f = Observable.just(6),
        g = Observable.just(7),
        h = Observable.just(8),
        i = Observable.just(9);

    Stream<List<int>> observable = Observable.zip9(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh, int eighth, int ninth) =>
            [
              first,
              second,
              third,
              fourth,
              fifth,
              sixth,
              seventh,
              eighth,
              ninth
            ]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip.single.subscription', () async {
    final observable = Observable.zip2(
        Observable.just(1), Observable.just(1), (int a, int b) => a + b);

    observable.listen(null);
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.zip.asBroadcastStream', () async {
    final testStream = StreamController<bool>()
      ..add(true)
      ..add(false)
      ..add(true)
      ..add(false)
      ..add(true)
      ..close(); // ignore: unawaited_futures

    final observable = Observable.zip3(
        Stream.periodic(const Duration(milliseconds: 1), (count) => count)
            .take(4),
        Stream.fromIterable(const [1, 2, 3, 4, 5, 6, 7, 8, 9]),
        testStream.stream,
        (int a, int b, bool c) => [a, b, c]).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.zip.error.shouldThrowA', () async {
    final observableWithError = Observable.zip2(
      Observable.just(1),
      Observable.just(2),
      (int a, int b) => throw Exception(),
    );

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  /*test('rx.Observable.zip.error.shouldThrowB', () {
    expect(
        () => Observable.zip2(
             new Observable.just(1), null, (int a, _) => null),
        throwsArgumentError);
  });

  test('rx.Observable.zip.error.shouldThrowC', () {
    expect(() => new ZipStream<num>(null, () {}), throwsArgumentError);
  });

  test('rx.Observable.zip.error.shouldThrowD', () {
    expect(() => new ZipStream<num>(<Stream<dynamic>>[], () {}),
        throwsArgumentError);
  });*/

  test('rx.Observable.zip.pause.resume.A', () async {
    StreamSubscription<int> subscription;
    final stream = Observable.zip2(
        Observable.just(1), Observable.just(2), (int a, int b) => a + b);

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 3);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.zip.pause.resume.B', () async {
    final first = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [1, 2, 3, 4][index]),
        second = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [5, 6, 7, 8][index]),
        last = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [9, 10, 11, 12][index]);

    StreamSubscription<Iterable<num>> subscription;
    subscription =
        Observable.zip3(first, second, last, (num a, num b, num c) => [a, b, c])
            .listen(expectAsync1((value) {
      expect(value.elementAt(0), 1);
      expect(value.elementAt(1), 5);
      expect(value.elementAt(2), 9);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<void>.delayed(const Duration(milliseconds: 80)));
  });
}
