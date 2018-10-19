import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.concatMap', () async {
    const expectedOutput = [1, 1, 2, 2, 3, 3];
    var count = 0;

    new Observable(_getStream()).concatMap(_getOtherStream).listen(
        expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length), onDone: expectAsync0(() {
      expect(true, true);
    }));
  });

  test('rx.Observable.concatMap.error.shouldThrow', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .concatMap(_getOtherStream);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.concatMap.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream =
        new Observable.just(0).concatMap((_) => new Observable.just(1));

    subscription = stream.listen(expectAsync1((value) {
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
    final stream = new Observable(_getStream()).concatMap(_getOtherStream);

    // Cancel the subscription before any events come through
    subscription = stream.listen(
        expectAsync1((value) {
          expect(true, isFalse);
        }, count: 0),
        onError: expectAsync2((Exception e, StackTrace s) {
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

Stream<int> _getStream() => new Stream.fromIterable(const [1, 2, 3]);

Stream<int> _getOtherStream(int value) {
  final controller = new StreamController<int>();

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
