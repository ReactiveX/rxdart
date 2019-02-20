import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.contains', () async {
    final actual = await Observable.just(1).contains(1);

    await expectLater(actual, true);
  });
}
