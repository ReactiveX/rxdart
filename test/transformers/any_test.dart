import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.any', () async {
    final actual = await Observable.just(1).any((val) => val == 1);

    await expectLater(actual, true);
  });
}
