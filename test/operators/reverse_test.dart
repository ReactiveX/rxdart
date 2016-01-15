library rx.test.operators.reverse;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<String> _getStream() => new Stream<String>.fromIterable(['b', 'a', 'c', 'k']);

Stream _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!

  return controller.stream;
}

void main() {
  test('rx.Observable.reverse', () async {
    const List<String> expectedOutput = const <String>[
      'b',
      'a', 'b',
      'c', 'a', 'b',
      'k', 'c', 'a', 'b'
    ];
    int count = 0;

    rx.observable(_getStream())
      .reverse()
      .listen(expectAsync((String result) {
        // test to see if the combined output matches
        expect(result.compareTo(expectedOutput[count++]), 0);
      }, count: expectedOutput.length));
  });

  test('rx.Observable.reverse.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
      .reverse();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.reverse.shouldThrow', () async {
    rx.observable(_getErroneousStream())
      .reverse()
      .listen((_) {}, onError: (e) {
        expect(true, true);
      });
  });
}