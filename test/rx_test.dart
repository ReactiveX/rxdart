library test.rx;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rx.dart' as rx;

List<Stream> _getStreams(int count) {
  Stream a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(3);
  Stream b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
  StreamController<bool> c = new StreamController<bool>()..add(true)..close();

  return <Stream>[a, b, c.stream];
}

Stream _getErroneousStream() {
  return new rx.Observable.combineLatest(_getStreams(3),
      (int a_value, int b_value, /* should be bool, not int, so throw */ int c_value) {
    return '$a_value $b_value $c_value';
  });
}

void main() {
  test('rx.Observable.combineLatest', () async {
    const List<String> expectedOutput = const <String>['0 4 true', '1 4 true', '2 4 true'];
    int count = 0;

    Stream<String> observable = new rx.Observable.combineLatest(_getStreams(3),
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    });

    observable.listen(expectAsync((String result) {
      // test to see if the combined output matches
      expect(result.compareTo(expectedOutput[count++]), 0);
    }, count: 3));
  });

  test('rx.Observable.combineLatest.asBroadcastStream', () async {
    Stream<String> observable = new rx.Observable.combineLatest(_getStreams(3),
        (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    }, asBroadcastStream: true);

    // listen twice on same stream
    await observable.first;
    await observable.last;
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.combineLatest.error.shouldThrow.A', () async {
    Stream<String> observableWithError = new rx.Observable.combineLatest(_getStreams(3),
        (int a_value, int b_value, /* should be bool, not int, so throw */ int c_value) {
      return '$a_value $b_value $c_value';
    });

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });

  test('rx.Observable.combineLatest.error.shouldThrow.B', () async {
    Stream<String> observableWithError = new rx.Observable.combineLatest(_getStreams(3)..add(_getErroneousStream()),
        (int a_value, int b_value, bool c_value, _) {
      return '$a_value $b_value $c_value $_';
    });

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });

  test('rx.Observable.combineLatestMap', () async {
    Stream a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(3);
    Stream b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
    const List<Map<String, dynamic>> expectedOutput = const <Map<String, dynamic>>[const {'a': 0, 'b': 4}, const {'a': 1, 'b': 4}, const {'a': 2, 'b': 4}];
    int count = 0;

    Stream<Map<String, dynamic>> observable = new rx.Observable<Map<String, dynamic>>.combineLatestMap({
      'a': a,
      'b': b
    });

    observable.listen(expectAsync((Map<String, dynamic> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count]['a'], result['a']);
      expect(expectedOutput[count]['b'], result['b']);
      count++;
    }, count: 3));
  });

  test('rx.Observable.merge', () async {
    Stream a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(3);
    Stream b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
    const List<int> expectedOutput = const <int>[1, 2, 3, 4, 0, 1, 2];
    int count = 0;

    Stream<int> observable = new rx.Observable<int>.merge(<Stream>[a, b]);

    observable.listen(expectAsync((int result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

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

  test('rx.Observable.debounce', () async {
    StreamController<int> controller = new StreamController<int>();

    new Timer(const Duration(milliseconds: 100), () => controller.add(1));
    new Timer(const Duration(milliseconds: 200), () => controller.add(2));
    new Timer(const Duration(milliseconds: 300), () => controller.add(3));
    new Timer(const Duration(milliseconds: 400), () {
      controller.add(4);
      controller.close();
    });

    rx.observable(controller.stream)
      .debounce(const Duration(milliseconds: 200))
      .listen(expectAsync((int result) {
        expect(result, 4);
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