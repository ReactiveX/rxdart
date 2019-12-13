import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.max', () async {
    await expectLater(_getStream().max(), completion(9));
  });

  test('Rx.max.with.comparator', () async {
    await expectLater(
        Stream<String>.fromIterable(<String>['one', 'two', 'three'])
            .max((String a, String b) => a.length - b.length),
        completion('three'));
  });
}

class ErrorComparator implements Comparable<ErrorComparator> {
  @override
  int compareTo(ErrorComparator other) {
    throw Exception();
  }
}

Stream<int> _getStream() =>
    Stream<int>.fromIterable(const <int>[2, 3, 3, 5, 2, 9, 1, 2, 0]);
