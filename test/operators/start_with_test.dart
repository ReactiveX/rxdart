import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() =>
    new Stream<int>.fromIterable(const <int>[1, 2, 3, 4]);

void main() {
  test('rx.Observable.startWith', () async {
    const List<int> expectedOutput = const <int>[5, 1, 2, 3, 4];
    int count = 0;

    observable(_getStream()).startWith(5).listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.startWith.asBroadcastStream', () async {
    Stream<int> stream =
        observable(_getStream().asBroadcastStream()).startWith(5);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.startWith.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).startWith(5);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });
}
