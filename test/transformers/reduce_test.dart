import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.reduce', () async {
    final actual = await Observable.fromIterable(const [1, 2, 3])
        .reduce((int prev, int val) => prev + val);

    await expectLater(actual, 6);
  });
}
