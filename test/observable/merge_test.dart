import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

List<Stream<num>> _getStreams() {
  Stream<num> a = new Stream<num>.periodic(const Duration(milliseconds: 20), (num count) => count).take(3);
  Stream<num> b = new Stream<num>.fromIterable(const <num>[1, 2, 3, 4]);

  return <Stream<num>>[a, b];
}

Stream<num> _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!
  controller.close();

  return controller.stream;
}

void main() {
  test('rx.Observable.merge', () async {
    const List<num> expectedOutput = const <num>[1, 2, 3, 4, 0, 1, 2];
    int count = 0;

    Stream<num> observable = new rx.Observable<num>.merge(_getStreams());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.merge.asBroadcastStream', () async {
    Stream<num> observable = new rx.Observable<num>.merge(_getStreams(), asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.merge.error.shouldThrow', () async {
    Stream<num> observableWithError = new rx.Observable<num>.merge(_getStreams()..add(_getErroneousStream()));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}