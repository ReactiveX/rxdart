import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.single', () async {
    final int actual = await new Observable<int>.just(1).single;

    await expectLater(actual, 1);
  });

  test('rx.Observable.single.throws', () async {
    try {
      await new Observable<int>.fromIterable(<int>[1, 2, 3]).single;
    } catch (e) {
      await expectLater(e, isStateError);
    }
  });
}
