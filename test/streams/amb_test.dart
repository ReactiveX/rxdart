import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  group('AmbStream', () {
    test('emits only the items from the first stream to emit items', () async {
      final Stream<num> first =
          new TimerStream<num>(1, new Duration(milliseconds: 10));
      final Stream<num> second =
          new TimerStream<num>(2, new Duration(milliseconds: 20));

      await expect(new AmbStream<num>(<Stream<num>>[first, second]),
          emitsInOrder(<dynamic>[1, emitsDone]));
    });

    test('emits done when the fastest stream ends without emitting', () async {
      final Stream<num> first = new Stream<num>.empty();
      final Stream<num> second =
          new TimerStream<num>(2, new Duration(milliseconds: 20));

      await expect(new AmbStream<num>(<Stream<num>>[first, second]), emitsDone);
    });

    test('can only be listened to once', () async {
      final Stream<num> first =
          new TimerStream<num>(1, new Duration(milliseconds: 50));

      Stream<num> observable = new AmbStream<num>(<Stream<num>>[first]);

      observable.listen(null);
      await expect(() => observable.listen(null), throwsA(isStateError));
    });
  });
}
