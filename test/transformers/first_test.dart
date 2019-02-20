import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.first', () async {
    final actual = await Observable.fromIterable(const [1, 2, 3]).first;

    await expectLater(actual, 1);
  });
}
