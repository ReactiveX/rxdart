import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
  Stream<int> a = new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

  return a;
}

void main() {
  test('rx.Observable.stream', () async {
    const List<int> expectedOutput = const <int>[1, 2, 3, 4];
    int count = 0;

    Stream<int> stream = new Observable<int>(_getStream());

    await expect(stream is Stream<int>, true);
    await expect(stream is Observable<int>, true);

    stream.listen(expectAsync1((int result) {
      // test to see if the combined output matches
      expect(result, expectedOutput[count++]);
    }, count: expectedOutput.length));
  });

  test('rx.Observable.stream.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(true, true);
  });

  test('rx.Observable.stream.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });
}
