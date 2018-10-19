import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [1, 2, 3]);

Stream<int> _getOtherStream(int value) {
  final controller = new StreamController<int>();

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
    const expectedOutput = [3, 2, 1];
    var count = 0;

    new Observable(_getStream())
        .flatMap(_getOtherStream)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.reusable', () async {
    final transformer = new FlatMapStreamTransformer<int, int>(_getOtherStream);
    const expectedOutput = [3, 2, 1];
    var countA = 0, countB = 0;

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length));

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.asBroadcastStream', () async {
    final stream = new Observable(_getStream().asBroadcastStream())
        .flatMap(_getOtherStream);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.flatMap.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<int>(new Exception()))
            .flatMap(_getOtherStream);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.flatMap.error.shouldThrowB', () async {
    final observableWithError = new Observable.just(1).flatMap(
        (_) => new ErrorStream<void>(new Exception('Catch me if you can!')));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.flatMap.error.shouldThrowC', () async {
    final observableWithError = new Observable.just(1)
        .flatMap<void>((_) => throw new Exception('oh noes!'));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.flatMap.pause.resume', () async {
    StreamSubscription<int> subscription;
    final stream =
        new Observable.just(0).flatMap((_) => new Observable.just(1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.flatMap.chains', () {
    expect(
      Observable.just(1)
          .flatMap((_) => Observable.just(2))
          .flatMap((_) => Observable.just(3)),
      emitsInOrder(<dynamic>[3, emitsDone]),
    );
  });
}
