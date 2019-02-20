import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.last', () async {
    final actual = await Observable.fromIterable(const [1, 2, 3]).last;

    await expectLater(actual, 3);
  });
}
