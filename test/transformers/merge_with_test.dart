import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.mergeWith', () async {
    final delayedStream = Rx.timer(1, Duration(milliseconds: 10));
    final immediateStream = Stream.value(2);
    const expected = [2, 1];
    var count = 0;

    delayedStream.mergeWith([immediateStream]).listen(expectAsync1((result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });

  test('Rx.flatMap accidental broadcast', () async {
    final controller = StreamController<int>();

    final stream = controller.stream.mergeWith([Stream<int>.empty()]);

    stream.listen(null);
    expect(() => stream.listen(null), throwsStateError);

    controller.add(1);
  });
}
