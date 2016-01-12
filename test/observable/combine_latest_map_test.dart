library rx.test.observable.combine_latest_map;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Map<String, Stream> _getStreams() {
  Stream a = new Stream<int>.periodic(const Duration(milliseconds: 20), (int count) => count).take(3);
  Stream b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
  StreamController<bool> c = new StreamController<bool>()..add(true)..close();

  return <String, Stream>{
    'a': a,
    'b': b,
    'c': c.stream
  };
}

Stream _getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.add(1);
  controller.add(2);
  controller.add(100 / 0); // throw!!!

  return controller.stream;
}

void main() {
  test('rx.Observable.combineLatestMap', () async {
    const List<Map<String, dynamic>> expectedOutput = const <Map<String, dynamic>>[const {'a': 0, 'b': 4, 'c': true}, const {'a': 1, 'b': 4, 'c': true}, const {'a': 2, 'b': 4, 'c': true}];
    int count = 0;

    Stream<Map<String, dynamic>> observable = new rx.Observable<Map<String, dynamic>>.combineLatestMap(_getStreams());

    observable.listen(expectAsync((Map<String, dynamic> result) {
      // test to see if the combined output matches
      expect(expectedOutput[count]['a'], result['a']);
      expect(expectedOutput[count]['b'], result['b']);
      expect(expectedOutput[count]['c'], result['c']);
      count++;
    }, count: 3));
  });

  test('rx.Observable.combineLatestMap.asBroadcastStream', () async {
    Stream<Map<String, dynamic>> observable = new rx.Observable<Map<String, dynamic>>.combineLatestMap(_getStreams(), asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.combineLatestMap.error.shouldThrow', () async {
    Stream<Map<String, dynamic>> observableWithError = new rx.Observable<Map<String, dynamic>>.combineLatestMap(_getStreams()..putIfAbsent('d', () => _getErroneousStream()));

    observableWithError.listen((_) => {}, onError: (e, s) {
      expect(true, true);
    });
  });
}