import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> get streamA =>
    Stream<int>.periodic(const Duration(milliseconds: 1), (int count) => count)
        .take(3);

Stream<int> get streamB => Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

Stream<bool> get streamC {
  final controller = StreamController<bool>()
    ..add(true)
    ..close();

  return controller.stream;
}

void main() {
  test('rx.Observable.combineLatestList', () async {
    final combined = Observable.combineLatestList<int>([
      Observable.fromIterable([1, 2, 3]),
      Observable.just(2),
      Observable.just(3),
    ]);

    expect(
      combined,
      emitsInOrder(<dynamic>[
        [1, 2, 3],
        [2, 2, 3],
        [3, 2, 3],
      ]),
    );
  });

  test('rx.Observable.combineLatest', () async {
    final combined = Observable.combineLatest<int, int>(
      [
        Observable.fromIterable([1, 2, 3]),
        Observable.just(2),
        Observable.just(3),
      ],
      (values) => values.fold(0, (acc, val) => acc + val),
    );

    expect(
      combined,
      emitsInOrder(<dynamic>[6, 7, 8]),
    );
  });

  test('rx.Observable.combineLatest3', () async {
    const expectedOutput = ['0 4 true', '1 4 true', '2 4 true'];
    var count = 0;

    final observable = Observable.combineLatest3(streamA, streamB, streamC,
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    });

    observable.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result.compareTo(expectedOutput[count++]), 0);
    }, count: 3));
  });

  test('rx.Observable.combineLatest3.single.subscription', () async {
    final observable = Observable.combineLatest3(streamA, streamB, streamC,
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    });

    observable.listen(null);
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.combineLatest2', () async {
    const expected = [
      [1, 2],
      [2, 2]
    ];
    var count = 0;

    var a = Observable.fromIterable(const [1, 2]), b = Observable.just(2);

    final observable = Observable.combineLatest2(
        a, b, (int first, int second) => [first, second]);

    observable.listen(expectAsync1((result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });

  test('rx.Observable.combineLatest2.throws', () async {
    var a = Observable.just(1), b = Observable.just(2);

    final observable = Observable.combineLatest2(a, b, (int first, int second) {
      throw Exception();
    });

    observable.listen(null, onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.combineLatest3', () async {
    const expected = [1, "2", 3.0];

    var a = Observable<int>.just(1),
        b = Observable<String>.just("2"),
        c = Observable<double>.just(3.0);

    final observable = Observable.combineLatest3(a, b, c,
        (int first, String second, double third) => [first, second, third]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.combineLatest4', () async {
    const expected = [1, 2, 3, 4];

    var a = Observable.just(1),
        b = Observable<int>.just(2),
        c = Observable<int>.just(3),
        d = Observable<int>.just(4);

    final observable = Observable.combineLatest4(
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

  test('rx.Observable.combineLatest5', () async {
    const expected = [1, 2, 3, 4, 5];

    var a = Observable<int>.just(1),
        b = Observable<int>.just(2),
        c = Observable<int>.just(3),
        d = Observable<int>.just(4),
        e = Observable<int>.just(5);

    final observable = Observable.combineLatest5(
        a,
        b,
        c,
        d,
        e,
        (int first, int second, int third, int fourth, int fifth) =>
            <int>[first, second, third, fourth, fifth]);

    observable.listen(expectAsync1((result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.combineLatest6', () async {
    const expected = [1, 2, 3, 4, 5, 6];

    var a = Observable<int>.just(1),
        b = Observable<int>.just(2),
        c = Observable<int>.just(3),
        d = Observable<int>.just(4),
        e = Observable<int>.just(5),
        f = Observable<int>.just(6);

    Stream<List<int>> observable = Observable.combineLatest6(
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

  test('rx.Observable.combineLatest7', () async {
    const expected = [1, 2, 3, 4, 5, 6, 7];

    var a = Observable<int>.just(1),
        b = Observable<int>.just(2),
        c = Observable<int>.just(3),
        d = Observable<int>.just(4),
        e = Observable<int>.just(5),
        f = Observable<int>.just(6),
        g = Observable<int>.just(7);

    final observable = Observable.combineLatest7(
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

  test('rx.Observable.combineLatest8', () async {
    const expected = [1, 2, 3, 4, 5, 6, 7, 8];

    var a = Observable<int>.just(1),
        b = Observable<int>.just(2),
        c = Observable<int>.just(3),
        d = Observable<int>.just(4),
        e = Observable<int>.just(5),
        f = Observable<int>.just(6),
        g = Observable<int>.just(7),
        h = Observable<int>.just(8);

    final observable = Observable.combineLatest8(
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

  test('rx.Observable.combineLatest9', () async {
    const expected = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    var a = Observable<int>.just(1),
        b = Observable<int>.just(2),
        c = Observable<int>.just(3),
        d = Observable<int>.just(4),
        e = Observable<int>.just(5),
        f = Observable<int>.just(6),
        g = Observable<int>.just(7),
        h = Observable<int>.just(8),
        i = Observable<int>.just(9);

    final observable = Observable.combineLatest9(
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

  test('rx.Observable.combineLatest.asBroadcastStream', () async {
    final observable = Observable.combineLatest3(streamA, streamB, streamC,
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    }).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.combineLatest.error.shouldThrowA', () async {
    final observableWithError = Observable.combineLatest4(Observable.just(1),
        Observable.just(1), Observable.just(1), ErrorStream<int>(Exception()),
        (int a_value, int b_value, int c_value, dynamic _) {
      return '$a_value $b_value $c_value $_';
    });

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.combineLatest.error.shouldThrowB', () async {
    final observableWithError = Observable.combineLatest3(
        Observable.just(1), Observable.just(1), Observable.just(1),
        (int a_value, int b_value, int c_value) {
      throw Exception('oh noes!');
    });

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  /*test('rx.Observable.combineLatest.error.shouldThrowC', () {
    expect(
        () => Observable.combineLatest3(new Observable<num>.just(1),
            new Observable<num>.just(1), new Observable<num>.just(1), null),
        throwsArgumentError);
  });

  test('rx.Observable.combineLatest.error.shouldThrowD', () {
    expect(() => new CombineLatestStream<num>(null, null), throwsArgumentError);
  });

  test('rx.Observable.combineLatest.error.shouldThrowE', () {
    expect(() => new CombineLatestStream<num>(<Stream<num>>[], null),
        throwsArgumentError);
  });*/

  test('rx.Observable.combineLatest.pause.resume', () async {
    final first = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [1, 2, 3, 4][index]),
        second = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [5, 6, 7, 8][index]),
        last = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [9, 10, 11, 12][index]);

    StreamSubscription<Iterable<num>> subscription;
    // ignore: deprecated_member_use
    subscription = Observable.combineLatest3(
            first, second, last, (int a, int b, int c) => [a, b, c])
        .listen(expectAsync1((value) {
      expect(value.elementAt(0), 1);
      expect(value.elementAt(1), 5);
      expect(value.elementAt(2), 9);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
