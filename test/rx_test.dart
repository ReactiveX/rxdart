library test.rx;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rx.dart' as rx;

import 'observable/stream_test.dart' as stream_test;
import 'observable/combine_latest_test.dart' as combine_latest_test;
import 'observable/combine_latest_map_test.dart' as combine_latest_map_test;
import 'observable/merge_test.dart' as merge_test;

import 'operators/debounce_test.dart' as debounce_test;

void main() {
  stream_test.main();
  combine_latest_test.main();
  combine_latest_map_test.main();
  merge_test.main();

  debounce_test.main();

  test('rx.Observable.retry', () async {
    Stream<int> testStream = new Stream<int>.fromIterable(const <int>[0, 1, 2, 3]).map((int i) {
      if (i < 3) throw new Error();

      return i;
    });

    rx.observable(testStream)
      .retry(3)
      .listen(expectAsync((int result) {
        expect(result, 3);
      }, count: 1));
  });

  test('rx.Observable.throttle', () async {
    StreamController<int> controller = new StreamController<int>();

    new Timer(const Duration(milliseconds: 100), () => controller.add(1));
    new Timer(const Duration(milliseconds: 200), () => controller.add(2));
    new Timer(const Duration(milliseconds: 300), () => controller.add(3));
    new Timer(const Duration(milliseconds: 400), () {
      controller.add(4);
      controller.close();
    });

    const List<int> expectedOutput = const <int>[1, 4];
    int count = 0;

    rx.observable(controller.stream)
      .throttle(const Duration(milliseconds: 250))
      .listen(expectAsync((int result) {
        expect(result, expectedOutput[count++]);
      }, count: 2));
  });

}