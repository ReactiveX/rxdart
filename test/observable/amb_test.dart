import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Observable.amb factory wraps AmbStream', () async {
    final Observable<int> first =
        new Observable<int>.timer(1, new Duration(milliseconds: 10));
    final Observable<int> second =
        new Observable<int>.timer(2, new Duration(milliseconds: 20));

    await expect(new Observable<int>.amb(<Stream<int>>[first, second]),
        emitsInOrder(<dynamic>[1, emitsDone]));
  });
}
