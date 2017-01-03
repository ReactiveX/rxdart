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
  test('rx.Observable.concat', () async {
    const List<num> expectedOutput = const <num>[0, 1, 2, 1, 2, 3, 4];
    int count = 0;

    Stream<num> observable = new rx.Observable<num>.concat(_getStreams());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concat.withBroadcastStreams', () async {
    const List<num> expectedOutput = const <num>[1, 2, 3, 4, 99, 98, 97, 96, 999, 998, 997];
    final StreamController<int> ctrlA = new StreamController<int>.broadcast();
    final StreamController<int> ctrlB = new StreamController<int>.broadcast();
    final StreamController<int> ctrlC = new StreamController<int>.broadcast();
    int x = 0, y = 100, z = 1000;
    int count = 0;

    new Timer.periodic(const Duration(milliseconds: 20), (_) {
      ctrlA.add(++x);
      ctrlB.add(--y);

      if (x <= 3) ctrlC.add(--z);

      if (x == 3) ctrlC.close();

      if (x == 4) {
        _.cancel();

        ctrlA.close();
        ctrlB.close();
      }
    });

    Stream<int> observable = new rx.Observable<int>.concat(<Stream<int>>[ctrlA.stream, ctrlB.stream, ctrlC.stream]);

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concat.asBroadcastStream', () async {
    Stream<num> observable = new rx.Observable<num>.concat(_getStreams(), asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.concat.error.shouldThrow', () async {
    Stream<num> observableWithError = new rx.Observable<num>.concat(_getStreams()..add(_getErroneousStream()));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}