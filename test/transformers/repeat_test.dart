import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [1, 2, 3, 4]);

void main() {
  test('rx.Observable.repeat', () async {
    const expectedOutput = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    var count = 0;

    new Observable(_getStream()).repeat(3).listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.repeat.reusable', () async {
    final transformer = new RepeatStreamTransformer<int>(3);
    const expectedOutput = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    var countA = 0, countB = 0;

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable(_getStream())
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.repeat.asBroadcastStream', () async {
    final stream = new Observable(_getStream().asBroadcastStream()).repeat(3);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.repeat.error.shouldThrowA', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception())).repeat(3);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
          expect(e, isException);
        }, count: 1));
  });

  test('rx.Observable.repeat.error.shouldThrowB', () {
    expect(() => new Observable.just(1).repeat(null), throwsArgumentError);
  });
}
