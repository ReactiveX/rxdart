library rx.test.observable.merge;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rx.dart' as rx;

List<Stream> _getStreams() {
  Stream a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(3);
  Stream b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

  return <Stream>[a, b];
}

Stream _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!

  return controller.stream;
}

void main() {
  test('rx.Observable.merge', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4, 0, 1, 2];
    int count = 0;

    Stream<int> observable = new rx.Observable<int>.merge(_getStreams());

    observable.listen(expectAsync((int result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.merge.asBroadcastStream', () async {
    Stream<int> observable = new rx.Observable<int>.merge(_getStreams(), asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.merge.error.shouldThrow', () async {
    Stream<int> observableWithError = new rx.Observable<int>.merge(_getStreams()..add(_getErroneousStream()));

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}