import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('onErrorClose', () {
    test('cancels a Stream when it emits an error', () {
      final stream = ConcatStream<int>([
        Stream.fromIterable([1]),
        Stream.error(Exception()),
        Stream.fromIterable([2]),
      ]);

      expect(
        stream.onErrorClose(),
        emitsInOrder(<dynamic>[1, emitsDone]),
      );
    });

    test('cancels a Stream when the predicate returns true', () {
      final stream = ConcatStream<int>([
        Stream.fromIterable([1]),
        Stream.error(Exception()),
        Stream.fromIterable([2]),
        Stream.error(StateError('Oh no')),
        Stream.fromIterable([3]),
      ]);

      expect(
        stream.onErrorClose((dynamic e) => e is StateError),
        emitsInOrder(<dynamic>[1, emitsError(isException), 2, emitsDone]),
      );
    });

    test('does not affect the Stream if no errors are emitted', () {
      final stream = ConcatStream<int>([
        Stream.fromIterable([1]),
        Stream.fromIterable([2]),
        Stream.fromIterable([3]),
      ]);

      expect(
        stream.onErrorClose(),
        emitsInOrder(<dynamic>[1, 2, 3, emitsDone]),
      );
    });
  });
}
