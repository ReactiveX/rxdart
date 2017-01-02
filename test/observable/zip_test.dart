library rx.test.observable.zip;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

List<Stream<dynamic>> _getStreams() {
  Stream<int> a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(4);
  Stream<int> b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]);
  StreamController<bool> c = new StreamController<bool>()..add(true)..add(false)..add(true)..add(false)..add(true)..close();

  return <Stream<dynamic>>[a, b, c.stream];
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
  test('rx.Observable.zip', () async {
    const List<List<dynamic>> expectedOutput = const <List<dynamic>>[const <dynamic>[0, 1, true], const <dynamic>[1, 2, false], const <dynamic>[2, 3, true], const <dynamic>[3, 4, false]];
    int count = 0;

    Stream<List<dynamic>> observable = new rx.Observable<List<dynamic>>.zip(_getStreams(), (int a, int b, bool c) => <dynamic>[a, b, c]);

    observable.listen(expectAsync1((List<dynamic> result) {
      // test to see if the combined output matches
      for (int i=0, len=result.length; i<len; i++)
        expect(result[i], expectedOutput[count][i]);

      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.zipThree', () async {
    const List<List<dynamic>> expectedOutput = const <List<dynamic>>[const <dynamic>[0, 1, true], const <dynamic>[1, 2, false], const <dynamic>[2, 3, true], const <dynamic>[3, 4, false]];
    int count = 0;

    Stream<int> a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(4);
    Stream<int> b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]);
    StreamController<bool> c = new StreamController<bool>()..add(true)..add(false)..add(true)..add(false)..add(true)..close();

    Stream<List<dynamic>> observable = rx.Observable.zipThree(
        a, b, c.stream, (int a, int b, bool c) => <dynamic>[a, b, c]
    );

    observable.listen(expectAsync1((List<dynamic> result) {
      // test to see if the combined output matches
      for (int i=0, len=result.length; i<len; i++)
        expect(result[i], expectedOutput[count][i]);

      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.zip.asBroadcastStream', () async {
    Stream<List<dynamic>> observable = new rx.Observable<List<dynamic>>.zip(_getStreams(), (int a, int b, bool c) => <dynamic>[a, b, c], asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.zip.error.shouldThrow', () async {
    Stream<List<dynamic>> observableWithError = new rx.Observable<List<dynamic>>.zip(_getStreams()..add(_getErroneousStream()), (int a, int b, bool c) => <dynamic>[a, b, c]);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}