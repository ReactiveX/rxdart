import 'package:test/test.dart';

void main() {
  test('Rx.distinct', () async {
    const expected = 1;

    final stream = Stream.fromIterable(const [expected, expected]).distinct();

    stream.listen(expectAsync1((actual) {
      expect(actual, expected);
    }));
  });
}
