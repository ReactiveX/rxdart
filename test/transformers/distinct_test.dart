import 'package:test/test.dart';

void main() {
  test('rx.Observable.distinct', () async {
    const expected = 1;

    final observable =
        Stream.fromIterable(const [expected, expected]).distinct();

    observable.listen(expectAsync1((actual) {
      expect(actual, expected);
    }));
  });
}
