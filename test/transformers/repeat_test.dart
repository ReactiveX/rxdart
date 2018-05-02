import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

void main() {
  test('rx.Observable.repeat', () async {
    const List<int> expectedOutput = const <int>[
      1,
      1,
      1,
      2,
      2,
      2,
      3,
      3,
      3,
      4,
      4,
      4
    ];
    int count = 0;

    new Observable<int>(_getStream())
        .repeat(3)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.repeat.reusable', () async {
    final RepeatStreamTransformer<int> transformer =
        new RepeatStreamTransformer<int>(3);
    const List<int> expectedOutput = const <int>[
      1,
      1,
      1,
      2,
      2,
      2,
      3,
      3,
      3,
      4,
      4,
      4
    ];
    int countA = 0, countB = 0;

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countA++], result);
        }, count: expectedOutput.length));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(expectedOutput[countB++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.repeat.asBroadcastStream', () async {
    Stream<int> stream =
        new Observable<int>(_getStream().asBroadcastStream()).repeat(3);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.repeat.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception())).repeat(3);

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
          expect(e, isException);
        }, count: 1));
  });

  test('rx.Observable.repeat.error.shouldThrowB', () {
    expect(() => new Observable<num>.just(1).repeat(null), throwsArgumentError);
  });
}
