import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Rx.flatMapIterable', () {
    test('transforms a Stream<Iterable<S>> into individual items', () {
      expect(
          Rx.range(1, 4)
              .flatMapIterable((int i) => Stream<List<int>>.value(<int>[i])),
          emitsInOrder(<dynamic>[1, 2, 3, 4, emitsDone]));
    });
  });
}
