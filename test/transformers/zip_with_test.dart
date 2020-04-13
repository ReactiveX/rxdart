import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.zipWith', () async {
    await expectLater(
        Stream.fromIterable(const [1, 2, 3, 4]).zipWith(
            Stream.fromIterable(const [2, 2, 2, 2])
                .delay(const Duration(milliseconds: 20)),
            (int one, int two) => one + two),
        emitsInOrder(const <int>[3, 4, 5, 6]));
  });
  test('Rx.zipWith accidental broadcast', () async {
    final controller = StreamController<int>();

    final stream =
        controller.stream.zipWith(Stream<int>.empty(), (_, dynamic __) => true);

    stream.listen(null);
    expect(() => stream.listen(null), throwsStateError);

    controller.add(1);
  });
}
