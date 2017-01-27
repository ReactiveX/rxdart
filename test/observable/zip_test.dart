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

    Stream<List<dynamic>> observable = new Observable.zip(<Stream>[
        new Stream<int>.periodic(
            const Duration(milliseconds: 1), (int count) => count).take(4),
        new Stream<int>.fromIterable(const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]),
        testStream.stream],
        (int a, int b, bool c) => <dynamic>[a, b, c]);

    observable.listen(expectAsync1((List<dynamic> result) {
      // test to see if the combined output matches
      for (int i = 0, len = result.length; i < len; i++)
        expect(result[i], expectedOutput[count][i]);

      count++;
    }, count: expectedOutput.length));
  });

  test('rx.Observable.zipTwo', () async {
    final List<int> expected = <int>[1, 2];

    // A purposely emits 2 items, b only 1
    Stream<int> a = new Observable<int>.fromIterable(<int>[1, 2]);
    Stream<int> b = new Observable<int>.just(2);

    Stream<List<int>> observable = Observable.zip2(
        a, b, (int first, int second) => <int>[first, second]);

    // Explicitly adding count: 1. It's important here, and tests the difference
    // between zip and combineLatest. If this was combineLatest, the count would
    // be two, and a second List<int> would be emitted.
    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }, count: 1));
  });

  test('rx.Observable.zip3', () async {
    // Verify the ability to pass through various types with safety
    const List<dynamic> expected = const <dynamic>[1, "2", 3.0];

    Stream<int> a = new Observable<int>.just(1);
    Stream<String> b = new Observable<String>.just("2");
    Stream<double> c = new Observable<double>.just(3.0);

    Stream<List<dynamic>> observable = Observable.zip3(
        a,
        b,
        c,
        (int first, String second, double third) =>
            <dynamic>[first, second, third]);

    observable.listen(expectAsync1((List<dynamic> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip4', () async {
    const List<int> expected = const <int>[1, 2, 3, 4];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);

    Stream<List<int>> observable = Observable.zip4(
        a,
        b,
        c,
        d,
        (int first, int second, int third, int fourth) =>
            <int>[first, second, third, fourth]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip5', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);

    Stream<List<int>> observable = Observable.zip5(
        a,
        b,
        c,
        d,
        e,
        (int first, int second, int third, int fourth, int fifth) =>
            <int>[first, second, third, fourth, fifth]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip6', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);

    Stream<List<int>> observable = Observable.zip6(
        a,
        b,
        c,
        d,
        e,
        f,
        (int first, int second, int third, int fourth, int fifth, int sixth) =>
            <int>[first, second, third, fourth, fifth, sixth]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip7', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6, 7];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);
    Stream<int> g = new Observable<int>.just(7);

    Stream<List<int>> observable = Observable.zip7(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh) =>
            <int>[first, second, third, fourth, fifth, sixth, seventh]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip8', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6, 7, 8];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);
    Stream<int> g = new Observable<int>.just(7);
    Stream<int> h = new Observable<int>.just(8);

    Stream<List<int>> observable = Observable.zip8(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh, int eighth) =>
            <int>[first, second, third, fourth, fifth, sixth, seventh, eighth]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip9', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);
    Stream<int> g = new Observable<int>.just(7);
    Stream<int> h = new Observable<int>.just(8);
    Stream<int> i = new Observable<int>.just(9);

    Stream<List<int>> observable = Observable.zip9(
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        (int first, int second, int third, int fourth, int fifth, int sixth,
                int seventh, int eighth, int ninth) =>
            <int>[
              first,
              second,
              third,
              fourth,
              fifth,
              sixth,
              seventh,
              eighth,
              ninth
            ]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.zip.asBroadcastStream', () async {
    StreamController<bool> testStream = new StreamController<bool>()
      ..add(true)
      ..add(false)
      ..add(true)
      ..add(false)
      ..add(true)
      ..close();

    Stream<List<dynamic>> observable = Observable.zip3(
        new Stream<int>.periodic(
            const Duration(milliseconds: 1), (int count) => count).take(4),
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
    Stream<int> observableWithError = Observable.zip2(
        new Observable<int>.just(1),
        new Observable<int>.just(2),
        (int a, int b) => throw new Exception());

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.zip.pause.resume', () async {
    StreamSubscription<int> subscription;
    Stream<int> observableWithError = Observable.zip2(
        new Observable<int>.just(1),
        new Observable<int>.just(2),
        (int a, int b) => a + b);

    subscription = observableWithError.listen(expectAsync1((int value) {
      expect(value, 3);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}
