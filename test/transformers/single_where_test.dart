import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.singleWhere', () async {
    final actual = await new Observable.fromIterable(const [1, 2, 3])
        .singleWhere((val) => val == 2);

    await expectLater(actual, 2);
  });

  test('rx.Observable.singleWhere.throws', () async {
    try {
      await new Observable.fromIterable(const [1, 2, 2])
          .singleWhere((val) => val == 2);
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });
}
