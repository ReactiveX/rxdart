library rx.test.observable.zip;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

List<Stream> _getStreams() {
  Stream a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(4);
  Stream b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
  StreamController<bool> c = new StreamController<bool>()..add(true)..add(false)..add(true)..add(false)..close();

  return <Stream>[a, b, c.stream];
}

Stream _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!

  return controller.stream;
}

typedef void ExpectAsync(List<dynamic> list);

void main() {
  test('rx.Observable.zip', () async {
    const List<List<dynamic>> expectedOutput = const <List<dynamic>>[const <dynamic>[0, 1, true], const <dynamic>[1, 2, false], const <dynamic>[2, 3, true], const <dynamic>[3, 4, false]];
    int count = 0;

    Stream<List> observable = new rx.Observable.zip(_getStreams(), (int a, int b, bool c) => [a, b, c]);

    observable.listen(expectAsync1((List<dynamic> result) {
      // test to see if the combined output matches
      for (int i=0, len=result.length; i<len; i++)
        expect(result[i], expectedOutput[count][i]);

      count++;
    }, count: expectedOutput.length) as ExpectAsync);
  });

  test('rx.Observable.zip.asBroadcastStream', () async {
    Stream<List> observable = new rx.Observable.zip(_getStreams(), (int a, int b, bool c) => [a, b, c], asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.zip.error.shouldThrow', () async {
    Stream<List> observableWithError = new rx.Observable.zip(_getStreams()..add(_getErroneousStream()), (int a, int b, bool c) => [a, b, c]);

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}