import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.concatWith', () async {
    final delayedStream = Rx.timer(1, Duration(milliseconds: 10));
    final immediateStream = Stream.value(2);
    const expected = [1, 2];
    var count = 0;

    delayedStream.concatWith([immediateStream]).listen(expectAsync1((result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });
}
