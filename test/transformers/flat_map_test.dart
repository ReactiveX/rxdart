import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  return new Stream<int>.fromIterable(<int>[1, 2, 3]);
}

Stream<int> _getOtherStream(int value) {
  StreamController<int> controller = new StreamController<int>();

  new Timer(
      // Reverses the order of 1, 2, 3 to 3, 2, 1 by delaying 1, and 2 longer
      // than they delay 3
      new Duration(milliseconds: value == 1 ? 15 : value == 2 ? 10 : 5), () {
    controller.add(value);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.flatMap', () async {
    const List<int> expectedOutput = const <int>[3, 2, 1];
    int count = 0;

    new Observable<int>(_getStream())
        .flatMap(_getOtherStream)
        .listen(expectAsync1((num result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.reusable', () async {
    final FlatMapStreamTransformer<int, int> transformer =
        new FlatMapStreamTransformer<int, int>(_getOtherStream);
    const List<int> expectedOutput = const <int>[3, 2, 1];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((num result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((num result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.asBroadcastStream', () async {
    Stream<num> stream = new Observable<int>(_getStream().asBroadcastStream())
        .flatMap(_getOtherStream);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.flatMap.error.shouldThrowA', () async {
    Stream<int> observableWithError =
        new Observable<int>(new ErrorStream<int>(new Exception()))
            .flatMap(_getOtherStream);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.flatMap.error.shouldThrowB', () async {
    Stream<int> observableWithError = new Observable<int>.just(1).flatMap(
        (_) => new ErrorStream<int>(new Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.flatMap.error.shouldThrowC', () async {
    Stream<int> observableWithError = new Observable<int>.just(1)
        .flatMap((_) => throw new Exception('oh noes!'));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.flatMap.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream =
        new Observable<int>.just(0).flatMap((_) => new Observable<int>.just(1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.flatMap.chains', () {
    expect(
      Observable<int>.just(1)
          .flatMap((int _) => Observable<int>.just(2))
          .flatMap((int _) => Observable<int>.just(3)),
      emitsInOrder(<dynamic>[3, emitsDone]),
    );
  });
}
