import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.elementAt', () async {
    final actual =
        await Observable.fromIterable(const [1, 2, 3, 4, 5]).elementAt(0);

    await expectLater(actual, 1);
  });
}
