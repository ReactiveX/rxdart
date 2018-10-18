import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

List<Stream<int>> _getStreams() {
  var a = new Stream.fromIterable(const [0, 1, 2]),
      b = new Stream.fromIterable(const [3, 4, 5]);

  return [a, b];
}

List<Stream<int>> _getStreamsIncludingEmpty() {
  var a = new Stream.fromIterable(const [0, 1, 2]),
      b = new Stream.fromIterable(const [3, 4, 5]),
      c = new Observable<int>.empty();

  return [c, a, b];
}

void main() {
  test('rx.Observable.concat', () async {
    const expectedOutput = [0, 1, 2, 3, 4, 5];
    var count = 0;

    final observable = new Observable.concat(_getStreams());

    observable.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concatEager.single.subscription', () async {
    final observable = new Observable.concat(_getStreams());

    observable.listen(null);
    await expectLater(() => observable.listen(null), throwsA(isStateError));
  });

  test('rx.Observable.concat.withEmptyStream', () async {
    const expectedOutput = [0, 1, 2, 3, 4, 5];
    var count = 0;

    final observable = new Observable.concat(_getStreamsIncludingEmpty());

    observable.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concat.withBroadcastStreams', () async {
    const expectedOutput = const [1, 2, 3, 4];
    final ctrlA = new StreamController<int>.broadcast(),
        ctrlB = new StreamController<int>.broadcast(),
        ctrlC = new StreamController<int>.broadcast();
    var x = 0, y = 100, z = 1000, count = 0;

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

    final observable =
        new Observable.concat([ctrlA.stream, ctrlB.stream, ctrlC.stream]);

    observable.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.concat.asBroadcastStream', () async {
    final observable = new Observable.concat(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    observable.listen(null);
    observable.listen(null);
    // code should reach here
    await expectLater(observable.isBroadcast, isTrue);
  });

  test('rx.Observable.concat.error.shouldThrowA', () async {
    final observableWithError = new Observable.concat(
        _getStreams()..add(new ErrorStream<int>(new Exception())));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.concat.error.shouldThrowB', () {
    expect(() => new Observable<int>.concat(null), throwsArgumentError);
  });

  test('rx.Observable.concat.error.shouldThrowC', () {
    expect(() => new Observable<int>.concat(const []), throwsArgumentError);
  });

  test('rx.Observable.concat.error.shouldThrowD', () {
    expect(
        () => [
              new Observable.concat([new Observable.just(1), null]),
              null
            ],
        throwsArgumentError);
  });
}
