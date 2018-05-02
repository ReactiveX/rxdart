import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

List<Stream<num>> _getStreams() {
  Stream<num> a = new Stream<num>.fromIterable(const <num>[0, 1, 2]);
  Stream<num> b = new Stream<num>.fromIterable(const <num>[3, 4, 5]);

  return <Stream<num>>[a, b];
}

List<Stream<num>> _getStreamsIncludingEmpty() {
  Stream<num> a = new Stream<num>.fromIterable(const <num>[0, 1, 2]);
  Stream<num> b = new Stream<num>.fromIterable(const <num>[3, 4, 5]);
  Stream<num> c = new Observable<num>.empty();

  return <Stream<num>>[c, a, b];
}

void main() {
  test('rx.Observable.concat', () async {
    const List<num> expectedOutput = const <num>[0, 1, 2, 3, 4, 5];
    int count = 0;

    Stream<num> observable = new Observable<num>.concat(_getStreams());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concatEager.single.subscription', () async {
    Stream<num> observable = new Observable<num>.concat(_getStreams());

    observable.listen((_) {});
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.concat.withEmptyStream', () async {
    const List<num> expectedOutput = const <num>[0, 1, 2, 3, 4, 5];
    int count = 0;

    Stream<num> observable =
        new Observable<num>.concat(_getStreamsIncludingEmpty());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concat.withBroadcastStreams', () async {
    const List<num> expectedOutput = const <num>[1, 2, 3, 4];
    final StreamController<int> ctrlA = new StreamController<int>.broadcast();
    final StreamController<int> ctrlB = new StreamController<int>.broadcast();
    final StreamController<int> ctrlC = new StreamController<int>.broadcast();
    int x = 0, y = 100, z = 1000;
    int count = 0;

    new Timer.periodic(const Duration(milliseconds: 1), (_) {
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

    Stream<int> observable = new Observable<int>.concat(
        <Stream<int>>[ctrlA.stream, ctrlB.stream, ctrlC.stream]);

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concat.asBroadcastStream', () async {
    Stream<num> observable =
        new Observable<num>.concat(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.concat.error.shouldThrowA', () async {
    Stream<num> observableWithError = new Observable<num>.concat(
        _getStreams()..add(new ErrorStream<num>(new Exception())));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.concat.error.shouldThrowB', () {
    expect(() => new Observable<num>.concat(null), throwsArgumentError);
  });

  test('rx.Observable.concat.error.shouldThrowC', () {
    expect(() => new Observable<num>.concat(<Stream<Null>>[]),
        throwsArgumentError);
  });

  test('rx.Observable.concat.error.shouldThrowD', () {
    expect(
        () => <Stream<num>>[
              new Observable<num>.concat(
                  <Stream<num>>[new Observable<num>.just(1), null]),
              null
            ],
        throwsArgumentError);
  });
}
