import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.concatWith', () async {
    final delayedStream = Rx.timer(1, Duration(milliseconds: 10));
    final immediateStream = Stream.value(2);
    const expected = [1, 2];
    var count = 0;

    delayedStream.concatWith(immediateStream).listen(expectAsync1((result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('Rx.concatWith accidental broadcast', () async {
    final controller = StreamController<int>();

    final stream = controller.stream.concatWith(Stream<int>.empty());

    stream.listen(null);
    expect(() => stream.listen(null), throwsStateError);

    controller.add(1);
  });

  test('Rx.concatWith single stream', () async {
    final s = Stream.fromIterable([1, 2, 3])
        .concatWith(Stream.fromIterable([4, 5, 6]));

    expect(() => s.listen(null), returnsNormally);
    expect(() => s.listen(null), throwsA(TypeMatcher<StateError>()));
  });

  test('Rx.concatWith broadcast stream', () async {
    final s = Stream.fromIterable([1, 2, 3])
        .asBroadcastStream()
        .concatWith(Stream.fromIterable([4, 5, 6]).asBroadcastStream());

    expect(() => s.listen(null), returnsNormally);
    expect(() => s.listen(null), returnsNormally);
  });
}
