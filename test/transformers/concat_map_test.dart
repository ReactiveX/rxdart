import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.concatMap', () async {
    const List<int> expectedOutput = const <int>[1, 1, 2, 2, 3, 3];
    int count = 0;

    new Observable<int>(_getStream()).concatMap(_getOtherStream).listen(
        expectAsync1((num result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length), onDone: expectAsync0(() {
      expect(true, true);
    }));
  });

  test('rx.Observable.concatMap.reusable', () async {
    final ConcatMapStreamTransformer<int, int> transformer = new ConcatMapStreamTransformer<int, int>(_getOtherStream);
    const List<int> expectedOutput = const <int>[1, 1, 2, 2, 3, 3];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream()).transform(transformer).listen(
        expectAsync1((int result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length), onDone: expectAsync0(() {
      expect(true, true);
    }));

    new Observable<int>(_getStream()).transform(transformer).listen(
        expectAsync1((int result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length), onDone: expectAsync0(() {
      expect(true, true);
    }));
  });

  test('rx.Observable.concatMap.asBroadcastStream', () async {
    Stream<num> stream = new Observable<int>(_getStream())
        .concatMap(_getOtherStream)
        .asBroadcastStream();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(stream.isBroadcast, isTrue);
  });

  test('rx.Observable.concatMap.error.shouldThrow', () async {
    Stream<int> observableWithError =
        new Observable<int>(new ErrorStream<int>(new Exception()))
            .concatMap(_getOtherStream);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.concatMap.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = new Observable<int>.just(0)
        .concatMap((_) => new Observable<int>.just(1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);
      subscription.cancel();
    }, count: 1));

    new Timer(new Duration(milliseconds: 10), () {
      subscription.pause();
      subscription.resume();
    });
  });

  test('rx.Observable.concatMap.cancel', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream =
        new Observable<int>(_getStream()).concatMap(_getOtherStream);

    // Cancel the subscription before any events come through
    subscription = stream.listen(
        expectAsync1((num value) {
          expect(true, isFalse);
        }, count: 0),
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(true, isFalse);
        }, count: 0),
        onDone: expectAsync0(() {
          expect(true, isFalse);
        }, count: 0));

    new Timer(new Duration(milliseconds: 5), () {
      subscription.cancel();
    });
  });
}

Stream<int> _getStream() {
  return new Stream<int>.fromIterable(<int>[1, 2, 3]);
}

Stream<int> _getOtherStream(int value) {
  StreamController<int> controller = new StreamController<int>();

  new Timer(
      // Reverses the order of 1, 2, 3 to 3, 2, 1 by delaying 1, and 2 longer
      // than it delays 3
      new Duration(milliseconds: value == 1 ? 20 : value == 2 ? 10 : 5), () {
    controller.add(value);
  });

  // Delay by a longer amount, with the same reversing effect
  new Timer(new Duration(milliseconds: value == 1 ? 30 : value == 2 ? 20 : 10),
      () {
    controller.add(value);
    controller.close();
  });

  return controller.stream;
}
