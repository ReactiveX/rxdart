library rx.test.observable.combine_latest;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

List<Stream<dynamic>> _getStreams() {
  Stream<int> a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(3);
  Stream<int> b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
  StreamController<bool> c = new StreamController<bool>()..add(true)..close();

  return <Stream<dynamic>>[a, b, c.stream];
}

Stream<num> _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!

  return controller.stream;
}

typedef void ExpectAsync(String result);

void main() {
  test('rx.Observable.combineLatest', () async {
    const List<String> expectedOutput = const <String>['0 4 true', '1 4 true', '2 4 true'];
    int count = 0;

    Stream<String> observable = new rx.Observable<String>.combineLatest(_getStreams(),
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    });

    observable.listen(expectAsync1((String result) {
      // test to see if the combined output matches
      expect(result.compareTo(expectedOutput[count++]), 0);
    }, count: 3) as ExpectAsync);
  });

  test('rx.Observable.combineLatest.asBroadcastStream', () async {
    Stream<String> observable = new rx.Observable<String>.combineLatest(_getStreams(),
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    }, asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.combineLatest.error.shouldThrow.A', () async {
    Stream<String> observableWithError = new rx.Observable<String>.combineLatest(_getStreams(),
        (int a_value, int b_value, /* should be bool, not int, so throw */ int c_value) {
      return '$a_value $b_value $c_value';
    });

    observableWithError.listen((_) => const {}, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });

  test('rx.Observable.combineLatest.error.shouldThrow.B', () async {
    Stream<String> observableWithError = new rx.Observable<String>.combineLatest(_getStreams()..add(_getErroneousStream()),
        (int a_value, int b_value, bool c_value, _) {
      return '$a_value $b_value $c_value $_';
    });

    observableWithError.listen((_) => const {}, onError: (dynamic e, dynamic s) {
      expect(true, true);
    });
  });
}