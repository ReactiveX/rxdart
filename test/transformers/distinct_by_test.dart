import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.distinctBy', () async {
    await expectLater(
        Stream.fromIterable(['123', 'abc']).distinctBy((value) => value.length),
        emitsInOrder(<dynamic>[
          '123',
          emitsDone
        ]));
    await expectLater(
        Stream.fromIterable(['123', 'abc', '1234']).distinctBy((value) => value.length),
        emitsInOrder(<dynamic>[
          '123',
          '1234',
          emitsDone
        ]));
    await expectLater(
        Stream.fromIterable(['1234', 'abc', '1234', 'abcd']).distinctBy((value) => value.length),
        emitsInOrder(<dynamic>[
          '1234',
          'abc',
          '1234',
          emitsDone
        ]));
  });

}
