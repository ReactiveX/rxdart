import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

List<Stream<dynamic>> _getStreams() {
  Stream<int> a = new Stream<int>.periodic(
      const Duration(milliseconds: 20), (int count) => count).take(3);
  Stream<int> b = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);
  StreamController<bool> c = new StreamController<bool>()
    ..add(true)
    ..close();

  return <Stream<dynamic>>[a, b, c.stream];
}

void main() {
  test('rx.Observable.combineLatest', () async {
    const List<String> expectedOutput = const <String>[
      '0 4 true',
      '1 4 true',
      '2 4 true'
    ];
    int count = 0;

    Stream<String> observable = new Observable<String>.combineLatest(
        _getStreams(), (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    });

    observable.listen(expectAsync1((String result) {
      // test to see if the combined output matches
      expect(result.compareTo(expectedOutput[count++]), 0);
    }, count: 3));
  });

  test('rx.Observable.combineLatest2', () async {
    final List<List<int>> expected = <List<int>>[
      <int>[1, 2],
      <int>[2, 2]
    ];
    int count = 0;

    Stream<int> a = new Observable<int>.fromIterable(<int>[1, 2]);
    Stream<int> b = new Observable<int>.just(2);

    Stream<List<int>> observable = Observable.combineLatest2(
        a, b, (int first, int second) => <int>[first, second]);

    observable.listen(expectAsync1((List<int> result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });

  test('rx.Observable.combineLatest2.throws', () async {
    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);

    Stream<List<int>> observable =
        Observable.combineLatest2(a, b, (int first, int second) {
      throw new Exception();
    });

    observable.listen((_) {}, onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.combineLatest3', () async {
    const List<dynamic> expected = const <dynamic>[1, "2", 3.0];

    Stream<int> a = new Observable<int>.just(1);
    Stream<String> b = new Observable<String>.just("2");
    Stream<double> c = new Observable<double>.just(3.0);

    Stream<List<dynamic>> observable = Observable.combineLatest3(
        a,
        b,
        c,
        (int first, String second, double third) =>
            <dynamic>[first, second, third]);

    observable.listen(expectAsync1((List<dynamic> result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.combineLatest4', () async {
    const List<int> expected = const <int>[1, 2, 3, 4];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);

    Stream<List<int>> observable = Observable.combineLatest4(
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

  test('rx.Observable.combineLatest5', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);

    Stream<List<int>> observable = Observable.combineLatest5(
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

  test('rx.Observable.combineLatest6', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);

    Stream<List<int>> observable = Observable.combineLatest6(
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

  test('rx.Observable.combineLatest7', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6, 7];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);
    Stream<int> g = new Observable<int>.just(7);

    Stream<List<int>> observable = Observable.combineLatest7(
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

  test('rx.Observable.combineLatest8', () async {
    const List<int> expected = const <int>[1, 2, 3, 4, 5, 6, 7, 8];

    Stream<int> a = new Observable<int>.just(1);
    Stream<int> b = new Observable<int>.just(2);
    Stream<int> c = new Observable<int>.just(3);
    Stream<int> d = new Observable<int>.just(4);
    Stream<int> e = new Observable<int>.just(5);
    Stream<int> f = new Observable<int>.just(6);
    Stream<int> g = new Observable<int>.just(7);
    Stream<int> h = new Observable<int>.just(8);

    Stream<List<int>> observable = Observable.combineLatest8(
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

  test('rx.Observable.combineLatest9', () async {
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

    Stream<List<int>> observable = Observable.combineLatest9(
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

  test('rx.Observable.combineLatest.asBroadcastStream', () async {
    Stream<String> observable = new Observable<String>.combineLatest(
        _getStreams(), (int a_value, int b_value, bool c_value) {
      return '$a_value $b_value $c_value';
    }, asBroadcastStream: true);

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.combineLatest.error.shouldThrow.A', () async {
    Stream<String> observableWithError =
        new Observable<String>.combineLatest(_getStreams(), (int a_value,
            int b_value, /* should be bool, not int, so throw */ int c_value) {
      return '$a_value $b_value $c_value';
    });

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e.toString(), contains("bool"));
        }, count: 3));
  });

  test('rx.Observable.combineLatest.error.shouldThrow.B', () async {
    Stream<String> observableWithError = new Observable<String>.combineLatest(
        _getStreams()..add(getErroneousStream()),
        (int a_value, int b_value, bool c_value, _) {
      return '$a_value $b_value $c_value $_';
    });

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
