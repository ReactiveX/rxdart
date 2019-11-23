import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/rx.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    Stream.periodic(const Duration(milliseconds: 22), (count) => count).take(7);

Stream<int> _getLatestFromStream() =>
    Stream.periodic(const Duration(milliseconds: 50), (count) => count).take(4);

Stream<int> _getLatestFromStream2() =>
    Stream.periodic(const Duration(milliseconds: 30), (count) => count).take(5);

Stream<int> _getLatestFromStream3() =>
    Stream.periodic(const Duration(milliseconds: 40), (count) => count).take(2);

Stream<int> _getLatestFromStream4() =>
    Stream.periodic(const Duration(milliseconds: 60), (count) => count)
        .take(10);

void main() {
  test('Rx.withLatestFrom', () async {
    const expectedOutput = [
      Pair(2, 0),
      Pair(3, 0),
      Pair(4, 1),
      Pair(5, 1),
      Pair(6, 2)
    ];
    var count = 0;

    _getStream()
        .withLatestFrom(
            _getLatestFromStream(), (first, int second) => Pair(first, second))
        .take(5)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('Rx.withLatestFrom.reusable', () async {
    final transformer = WithLatestFromStreamTransformer.with1<int, int, Pair>(
        _getLatestFromStream().asBroadcastStream(),
        (first, second) => Pair(first, second));
    const expectedOutput = [
      Pair(2, 0),
      Pair(3, 0),
      Pair(4, 1),
      Pair(5, 1),
      Pair(6, 2)
    ];
    var countA = 0, countB = 0;

    _getStream().transform(transformer).take(5).listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length));

    _getStream().transform(transformer).take(5).listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length));
  });

  test('Rx.withLatestFrom.asBroadcastStream', () async {
    final stream = _getStream().asBroadcastStream().withLatestFrom(
        _getLatestFromStream().asBroadcastStream(), (first, int second) => 0);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);

    await expectLater(true, true);
  });

  test('Rx.withLatestFrom.error.shouldThrowA', () async {
    final streamWithError = Stream<int>.error(Exception())
        .withLatestFrom(_getLatestFromStream(), (first, int second) => "Hello");

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.withLatestFrom.error.shouldThrowB', () {
    expect(
        () => Stream.value(1)
            .withLatestFrom(null, (first, int second) => "Hello"),
        throwsArgumentError);
  });

  test('Rx.withLatestFrom.error.shouldThrowC', () {
    expect(
        () => _getStream()
            .withLatestFrom<int, void>(_getLatestFromStream(), null),
        throwsArgumentError);
  });

  test('Rx.withLatestFrom.pause.resume', () async {
    StreamSubscription<Pair> subscription;
    const expectedOutput = [Pair(2, 0)];
    var count = 0;

    subscription = _getStream()
        .withLatestFrom(
            _getLatestFromStream(), (first, int second) => Pair(first, second))
        .take(1)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });

  test('Rx.withLatestFrom.otherEmitsNull', () async {
    const expected = Pair(1, null);
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom(
      Stream<int>.value(null),
      (a, int b) => Pair(a, b),
    );

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFrom.otherNotEmit', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom(
      Stream<int>.empty(),
      (a, int b) => Pair(a, b),
    );

    await expectLater(
      stream,
      emitsDone,
    );
  });

  test('Rx.withLatestFrom2', () async {
    const expectedOutput = [
      _Tuple(2, 0, 1),
      _Tuple(3, 0, 1),
      _Tuple(4, 1, 2),
      _Tuple(5, 1, 3),
      _Tuple(6, 2, 4),
    ];
    var count = 0;

    _getStream()
        .withLatestFrom2(
          _getLatestFromStream(),
          _getLatestFromStream2(),
          (item1, int item2, int item3) => _Tuple(item1, item2, item3),
        )
        .take(5)
        .listen(
          expectAsync1(
            (result) => expect(result, expectedOutput[count++]),
            count: expectedOutput.length,
          ),
        );
  });

  test('Rx.withLatestFrom3', () async {
    const expectedOutput = [
      _Tuple(2, 0, 1, 0),
      _Tuple(3, 0, 1, 1),
      _Tuple(4, 1, 2, 1),
      _Tuple(5, 1, 3, 1),
      _Tuple(6, 2, 4, 1),
    ];
    var count = 0;

    _getStream()
        .withLatestFrom3(
          _getLatestFromStream(),
          _getLatestFromStream2(),
          _getLatestFromStream3(),
          (item1, int item2, int item3, int item4) =>
              _Tuple(item1, item2, item3, item4),
        )
        .take(5)
        .listen(
          expectAsync1(
            (result) => expect(result, expectedOutput[count++]),
            count: expectedOutput.length,
          ),
        );
  });

  test('Rx.withLatestFrom4', () async {
    const expectedOutput = [
      _Tuple(2, 0, 1, 0, 0),
      _Tuple(3, 0, 1, 1, 0),
      _Tuple(4, 1, 2, 1, 0),
      _Tuple(5, 1, 3, 1, 1),
      _Tuple(6, 2, 4, 1, 1),
    ];
    var count = 0;

    _getStream()
        .withLatestFrom4(
          _getLatestFromStream(),
          _getLatestFromStream2(),
          _getLatestFromStream3(),
          _getLatestFromStream4(),
          (item1, int item2, int item3, int item4, int item5) =>
              _Tuple(item1, item2, item3, item4, item5),
        )
        .take(5)
        .listen(
          expectAsync1(
            (result) => expect(result, expectedOutput[count++]),
            count: expectedOutput.length,
          ),
        );
  });

  test('Rx.withLatestFrom5', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom5(
      Stream.value(2),
      Stream.value(3),
      Stream.value(4),
      Stream.value(5),
      Stream.value(6),
      (a, int b, int c, int d, int e, int f) => _Tuple(a, b, c, d, e, f),
    );
    const expected = _Tuple(1, 2, 3, 4, 5, 6);

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFrom6', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom6(
      Stream.value(2),
      Stream.value(3),
      Stream.value(4),
      Stream.value(5),
      Stream.value(6),
      Stream.value(7),
      (a, int b, int c, int d, int e, int f, int g) =>
          _Tuple(a, b, c, d, e, f, g),
    );
    const expected = _Tuple(1, 2, 3, 4, 5, 6, 7);

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFrom7', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom7(
      Stream.value(2),
      Stream.value(3),
      Stream.value(4),
      Stream.value(5),
      Stream.value(6),
      Stream.value(7),
      Stream.value(8),
      (a, int b, int c, int d, int e, int f, int g, int h) =>
          _Tuple(a, b, c, d, e, f, g, h),
    );
    const expected = _Tuple(1, 2, 3, 4, 5, 6, 7, 8);

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFrom8', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom8(
      Stream.value(2),
      Stream.value(3),
      Stream.value(4),
      Stream.value(5),
      Stream.value(6),
      Stream.value(7),
      Stream.value(8),
      Stream.value(9),
      (a, int b, int c, int d, int e, int f, int g, int h, int i) =>
          _Tuple(a, b, c, d, e, f, g, h, i),
    );
    const expected = _Tuple(1, 2, 3, 4, 5, 6, 7, 8, 9);

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFrom9', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFrom9(
      Stream.value(2),
      Stream.value(3),
      Stream.value(4),
      Stream.value(5),
      Stream.value(6),
      Stream.value(7),
      Stream.value(8),
      Stream.value(9),
      Stream.value(10),
      (a, int b, int c, int d, int e, int f, int g, int h, int i, int j) =>
          _Tuple(a, b, c, d, e, f, g, h, i, j),
    );
    const expected = _Tuple(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFromList', () async {
    final stream = Rx.timer(
      1,
      const Duration(microseconds: 100),
    ).withLatestFromList(
      [
        Stream.value(2),
        Stream.value(3),
        Stream.value(4),
        Stream.value(5),
        Stream.value(6),
        Stream.value(7),
        Stream.value(8),
        Stream.value(9),
        Stream.value(10),
      ],
    );
    const expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    await expectLater(
      stream,
      emits(expected),
    );
  });

  test('Rx.withLatestFromList.emptyList', () async {
    final stream = Stream.fromIterable([1, 2, 3]).withLatestFromList([]);

    await expectLater(
      stream,
      emitsInOrder(
        <List<int>>[
          [1],
          [2],
          [3],
        ],
      ),
    );
  });
}

class Pair {
  final int first;
  final int second;

  const Pair(this.first, this.second);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Pair &&
        this.first == other.first &&
        this.second == other.second;
  }

  @override
  int get hashCode {
    return first.hashCode ^ second.hashCode;
  }

  @override
  String toString() {
    return 'Pair{first: $first, second: $second}';
  }
}

class _Tuple {
  final int item1;
  final int item2;
  final int item3;
  final int item4;
  final int item5;
  final int item6;
  final int item7;
  final int item8;
  final int item9;
  final int item10;

  const _Tuple([
    this.item1,
    this.item2,
    this.item3,
    this.item4,
    this.item5,
    this.item6,
    this.item7,
    this.item8,
    this.item9,
    this.item10,
  ]);

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        other is _Tuple &&
            this.item1 == other.item1 &&
            this.item2 == other.item2 &&
            this.item3 == other.item3 &&
            this.item4 == other.item4 &&
            this.item5 == other.item5 &&
            this.item6 == other.item6 &&
            this.item7 == other.item7 &&
            this.item8 == other.item8 &&
            this.item9 == other.item9 &&
            this.item10 == other.item10;
  }

  @override
  int get hashCode {
    return this.item1.hashCode ^
        this.item2.hashCode ^
        this.item3.hashCode ^
        this.item4.hashCode ^
        this.item5.hashCode ^
        this.item6.hashCode ^
        this.item7.hashCode ^
        this.item8.hashCode ^
        this.item9.hashCode ^
        this.item10.hashCode;
  }

  @override
  String toString() {
    final values = [
      item1,
      item2,
      item3,
      item4,
      item5,
      item6,
      item7,
      item8,
      item9,
      item10,
    ];
    final s = values.join(', ');
    return 'Tuple { $s }';
  }
}
