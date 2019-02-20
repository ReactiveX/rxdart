import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.toSet', () async {
    final actual = await Observable.fromIterable(const [1, 2, 2]).toSet();
    final expected = const [1, 2].toSet();

    await expectLater(actual, expected);
  });
}
