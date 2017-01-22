import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.zip', () async {
    const List<List<dynamic>> expectedOutput = const <List<dynamic>>[
      const <dynamic>[0, 1, true],
      const <dynamic>[1, 2, false],
      const <dynamic>[2, 3, true],
      const <dynamic>[3, 4, false]
    ];
    int count = 0;

    StreamController<bool> testStream = new StreamController<bool>()
      ..add(true)
      ..add(false)
      ..add(true)
      ..add(false)
      ..add(true)
      ..close();

    Stream<List<dynamic>> observable = Observable.zipThree(
        new Stream<int>.periodic(
            const Duration(milliseconds: 20), (int count) => count).take(4),
        new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]),
        testStream.stream,
        (int a, int b, bool c) => <dynamic>[a, b, c]);

    observable.listen(expectAsync1((List<dynamic> result) {
      // test to see if the combined output matches
      for (int i = 0, len = result.length; i < len; i++)
        expect(result[i], expectedOutput[count][i]);

      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.zipThree', () async {
    const List<List<dynamic>> expectedOutput = const <List<dynamic>>[
      const <dynamic>[0, 1, true],
      const <dynamic>[1, 2, false],
      const <dynamic>[2, 3, true],
      const <dynamic>[3, 4, false]
    ];
    int count = 0;

    Stream<int> a = new Stream<int>.periodic(
        const Duration(milliseconds: 20), (int count) => count).take(4);
    Stream<int> b =
        new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]);
    StreamController<bool> c = new StreamController<bool>()
      ..add(true)
      ..add(false)
      ..add(true)
      ..add(false)
      ..add(true)
      ..close();

    Stream<List<dynamic>> observable = Observable.zipThree(
        a, b, c.stream, (int a, int b, bool c) => <dynamic>[a, b, c]);

    observable.listen(expectAsync1((List<dynamic> result) {
      // test to see if the combined output matches
      for (int i = 0, len = result.length; i < len; i++)
        expect(result[i], expectedOutput[count][i]);

      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.zip.asBroadcastStream', () async {
    StreamController<bool> testStream = new StreamController<bool>()
      ..add(true)
      ..add(false)
      ..add(true)
      ..add(false)
      ..add(true)
      ..close();

    Stream<List<dynamic>> observable = Observable.zipThree(
        new Stream<int>.periodic(
            const Duration(milliseconds: 20), (int count) => count).take(4),
        new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]),
        testStream.stream,
        (int a, int b, bool c) => <dynamic>[a, b, c],
        asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.zip.error.shouldThrow', () async {
    StreamController<num> testStream = new StreamController<num>();

    testStream.add(1);
    testStream.add(2);
    testStream.add(3);

    Stream<List<dynamic>> observableWithError = Observable.zipThree(
        new Stream<int>.periodic(
            const Duration(milliseconds: 20), (int count) => count).take(4),
        new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]),
        testStream.stream.map((_) {
      throw new Error();
      return _;
    }), (int a, int b, num c) => <dynamic>[a, b, c]);

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(true, true);
        }, count: 3));

    await testStream.close();
  });
}
