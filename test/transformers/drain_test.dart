import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.drain', () async {
    const expected = 2;

    final actual = await Observable.just(1).drain(expected);

    await expectLater(actual, expected);
  });
}
