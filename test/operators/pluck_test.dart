library rx.test.operators.pluck;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream _getStream() => new Stream.fromIterable([{'first': {2: {true: 'done!'}}}]);

void main() {
  test('rx.Observable.pluck', () async {
    rx.observable(_getStream())
        .pluck(['first', 2, true])
        .listen((String result) => expect(result, 'done!'));
  });

  test('rx.Observable.pluck.asBroadcastStream', () async {
    Stream<int> observable = rx.observable(_getStream().asBroadcastStream())
        .pluck(['first', 2, true]);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.pluck.error.shouldThrow.A', () async {
    rx.observable(_getStream())
      .pluck(['first', 3, true])
      .listen((_) {}, onError: (e) {
        expect(true, true);
      });
  });

  test('rx.Observable.pluck.error.shouldThrow.B', () async {
    rx.observable(_getStream())
      .pluck(['first', 2, false], throwOnNull: true)
      .listen((_) {}, onError: (e) {
        expect(true, true);
      });
  });
}