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
  test('rx.Observable.concatEager', () async {
    const List<num> expectedOutput = const <num>[0, 1, 2, 3, 4, 5];
    int count = 0;

    Stream<num> observable = new Observable<num>.concatEager(_getStreams());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concatEager.single.subscription', () async {
    Stream<num> observable = new Observable<num>.concatEager(_getStreams());

    observable.listen((_) {});
    await expectLater(() => observable.listen((_) {}), throwsA(isStateError));
  });

  test('rx.Observable.concatEager.withEmptyStream', () async {
    const List<num> expectedOutput = const <num>[0, 1, 2, 3, 4, 5];
    int count = 0;

    Stream<num> observable =
        new Observable<num>.concatEager(_getStreamsIncludingEmpty());

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concatEager.withBroadcastStreams', () async {
    const List<num> expectedOutput = const <num>[
      1,
      2,
      3,
      4,
      99,
      98,
      97,
      96,
      999,
      998,
      997
    ];
    final StreamController<int> ctrlA = new StreamController<int>.broadcast();
    final StreamController<int> ctrlB = new StreamController<int>.broadcast();
    final StreamController<int> ctrlC = new StreamController<int>.broadcast();
    int x = 0, y = 100, z = 1000;
    int count = 0;

    new Timer.periodic(const Duration(milliseconds: 10), (_) {
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

    Stream<int> observable = new Observable<int>.concatEager(
        <Stream<int>>[ctrlA.stream, ctrlB.stream, ctrlC.stream]);

    observable.listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concatEager.asBroadcastStream', () async {
    Stream<num> observable =
        new Observable<num>.concatEager(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.concatEager.error.shouldThrowA', () async {
    Stream<num> observableWithError = new Observable<num>.concatEager(
        _getStreams()..add(new ErrorStream<num>(new Exception())));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.concatEager.error.shouldThrowB', () {
    expect(() => new Observable<num>.concatEager(null), throwsArgumentError);
  });

  test('rx.Observable.concatEager.error.shouldThrowC', () {
    expect(() => new Observable<num>.concatEager(<Stream<num>>[]),
        throwsArgumentError);
  });

  test('rx.Observable.concatEager.error.shouldThrowD', () {
    expect(
        () => new Observable<num>.concatEager(
            <Stream<num>>[new Observable<num>.just(1), null]),
        throwsArgumentError);
  });

  test('rx.Observable.concatEager.pause.resume', () async {
    final Stream<num> first = new Stream<num>.periodic(
        const Duration(milliseconds: 10),
        (int index) => const <num>[1, 2, 3, 4][index]);
    final Stream<num> second = new Stream<num>.periodic(
        const Duration(milliseconds: 10),
        (int index) => const <num>[5, 6, 7, 8][index]);
    final Stream<num> last = new Stream<num>.periodic(
        const Duration(milliseconds: 10),
        (int index) => const <num>[9, 10, 11, 12][index]);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription =
        new Observable<num>.concatEager(<Stream<num>>[first, second, last])
            .listen(expectAsync1((num value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription
        .pause(new Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
