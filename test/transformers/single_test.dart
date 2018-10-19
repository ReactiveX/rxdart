import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.single', () async {
    final actual = await new Observable.just(1).single;

    await expectLater(actual, 1);
  });

  test('rx.Observable.single.throws', () async {
    try {
      await new Observable.fromIterable(const [1, 2, 3]).single;
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });
}
