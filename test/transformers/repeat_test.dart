import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [1, 2, 3, 4]);

void main() {
  test('rx.Observable.repeat', () async {
    const expectedOutput = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    var count = 0;

    new Observable(_getStream())
        .repeat<int>(3)
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.repeat.async', () async {
    const expectedOutput = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4];
    var count = 0;

    new Observable(_getStream())
        .repeat(3,
            sequenceFactory: (stream) => stream.asyncMap(
                (value) => new Future.delayed(
                    const Duration(milliseconds: 20), () => value)))
        .listen(expectAsync1((result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });
}
