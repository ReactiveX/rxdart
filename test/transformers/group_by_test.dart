import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  const List<String> expectedResults = const <String>['1: 2', '2: 2', '3: 1'];
  int index = 0;

  test('rx.Observable.groupBy', () async {
    StreamSubscription<String> subscription;

    subscription = new Observable<Map<String, int>>(
            new Stream<Map<String, int>>.fromIterable(<Map<String, int>>[
      <String, int>{'name': 1, 'value': 1},
      <String, int>{'name': 2, 'value': 2},
      <String, int>{'name': 3, 'value': 3},
      <String, int>{'name': 1, 'value': 4},
      <String, int>{'name': 2, 'value': 5}
    ]))
        .groupBy((Map<String, int> map) => map['name'])
        .flatMap((GroupByMap<int, Map<String, int>> groupByMap) async* {
      int len = await groupByMap.stream.length;

      yield '${groupByMap.key}: $len';
    }).listen(expectAsync1((String result) {
      expect(result, expectedResults[index++]);

      if (index == expectedResults.length) {
        subscription.cancel();
      }
    }, count: 3));

    subscription.pause();
    subscription.resume();
  });
}
