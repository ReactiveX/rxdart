import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('RangeStream', () async {
    final List<int> expected = <int>[1, 2, 3];
    int count = 0;

    Stream<int> stream = new RangeStream(1, 3);

    stream.listen(expectAsync1((int actual) {
      expect(actual, expected[count++]);
    }, count: expected.length));
  });

  test('RangeStream.single.subscription', () async {
    final RangeStream stream = new RangeStream(1, 5);

    stream.listen((_) {});
    await expectLater(() => stream.listen((_) {}), throwsA(isStateError));
  });

  test('RangeStream.single', () async {
    Stream<int> stream = new RangeStream(1, 1);

    stream.listen(expectAsync1((int actual) {
      expect(actual, 1);
    }, count: 1));
  });

  test('RangeStream.reverse', () async {
    final List<int> expected = <int>[3, 2, 1];
    int count = 0;

    Stream<int> stream = new RangeStream(3, 1);

    stream.listen(expectAsync1((int actual) {
      expect(actual, expected[count++]);
    }, count: expected.length));
  });

  test('rx.Observable.range', () async {
    final List<int> expected = <int>[1, 2, 3];
    int count = 0;

    Observable<int> observable = Observable.range(1, 3);

    observable.listen(expectAsync1((int actual) {
      expect(actual, expected[count++]);
    }, count: expected.length));
  });
}
