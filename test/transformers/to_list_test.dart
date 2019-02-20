import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.toList', () async {
    final actual = await Observable.fromIterable(const [1, 2, 3]).toList();
    const expected = [1, 2, 3];

    await expectLater(actual, expected);
  });
}
