import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.concatWith', () async {
    final delayedStream = Observable.timer(1, Duration(milliseconds: 10));
    final immediateStream = Observable.just(2);
    const expected = [1, 2];
    var count = 0;

    Observable(delayedStream)
        .concatWith([immediateStream]).listen(expectAsync1((result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });
}
