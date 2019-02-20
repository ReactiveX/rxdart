import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final a = Stream.fromIterable(const [1, 2, 3, 4]);

  return a;
}

void main() {
  test('rx.Observable.stream', () async {
    const expectedOutput = [1, 2, 3, 4];
    var count = 0;

    final stream = Observable(_getStream());

    await expectLater(stream is Stream<int>, true);
    await expectLater(stream is Observable<int>, true);

    stream.listen(expectAsync1((result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.stream.asBroadcastStream', () async {
    final stream = Observable(_getStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.stream.error.shouldThrow', () async {
    final observableWithError = Observable(ErrorStream<void>(Exception()));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });
}
