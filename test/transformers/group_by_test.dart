import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<Map<String, int>> getStream() {
  return new Stream<Map<String, int>>.fromIterable(<Map<String, int>>[
    <String, int>{'name': 1, 'value': 1},
    <String, int>{'name': 2, 'value': 2},
    <String, int>{'name': 3, 'value': 3},
    <String, int>{'name': 1, 'value': 4},
    <String, int>{'name': 2, 'value': 5}
  ]);
}

void main() {
  test('rx.Observable.groupBy', () async {
    const List<String> expectedResults = const <String>['1: 2', '2: 2', '3: 1'];
    StreamSubscription<String> subscription;
    int index = 0;

    subscription = new Observable<Map<String, int>>(getStream())
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

  test('rx.Observable.groupBy.reusable', () async {
    final GroupByStreamTransformer<Map<String, int>, int> transformer =
        new GroupByStreamTransformer<Map<String, int>, int>(
            (Map<String, int> map) => map['name']);
    const List<String> expectedResults = const <String>['1: 2', '2: 2', '3: 1'];
    StreamSubscription<String> subscriptionA, subscriptionB;
    int indexA = 0, indexB = 0;

    subscriptionA = new Observable<Map<String, int>>(getStream())
        .transform(transformer)
        .flatMap((GroupByMap<int, Map<String, int>> groupByMap) async* {
      int len = await groupByMap.stream.length;

      yield '${groupByMap.key}: $len';
    }).listen(expectAsync1((String result) {
      expect(result, expectedResults[indexA++]);

      if (indexA == expectedResults.length) {
        subscriptionA.cancel();
      }
    }, count: 3));

    subscriptionB = new Observable<Map<String, int>>(getStream())
        .transform(transformer)
        .flatMap((GroupByMap<int, Map<String, int>> groupByMap) async* {
      int len = await groupByMap.stream.length;

      yield '${groupByMap.key}: $len';
    }).listen(expectAsync1((String result) {
      expect(result, expectedResults[indexB++]);

      if (indexB == expectedResults.length) {
        subscriptionB.cancel();
      }
    }, count: 3));
  });
}
