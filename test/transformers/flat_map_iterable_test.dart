import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  group('Observable.flatMapIterable', () {
    test('transforms a Stream<Iterable<S>> into individual items', () {
      expect(
          Observable.range(1, 4).flatMapIterable(
              (int i) => new Observable<List<int>>.just(<int>[i])),
          emitsInOrder(<dynamic>[1, 2, 3, 4, emitsDone]));
    });
  });
}
