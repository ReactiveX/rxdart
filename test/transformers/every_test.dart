import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.every', () async {
    final actual =
        await Observable.fromIterable(const [1, 2, 3]).every((val) => val == 1);

    await expectLater(actual, isFalse);
  });
}
