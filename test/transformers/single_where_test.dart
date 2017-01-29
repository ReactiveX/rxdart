import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.singleWhere', () async {
    final int actual = await new Observable<int>.fromIterable(<int>[1, 2, 3])
        .singleWhere((int val) => val == 2);

    expect(actual, 2);
  });

  test('rx.Observable.singleWhere.throws', () async {
    try {
      await new Observable<int>.fromIterable(<int>[1, 2, 2])
          .singleWhere((int val) => val == 2);
    } catch (e) {
      expect(e, isStateError);
    }
  });
}
