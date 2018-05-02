import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.singleWhere', () async {
    final int actual = await new Observable<int>.fromIterable(<int>[1, 2, 3])
        .singleWhere((int val) => val == 2);

    await expectLater(actual, 2);
  });

  test('rx.Observable.singleWhere.throws', () async {
    try {
      await new Observable<int>.fromIterable(<int>[1, 2, 2])
          .singleWhere((int val) => val == 2);
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });
}
