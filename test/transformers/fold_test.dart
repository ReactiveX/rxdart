import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.fold', () async {
    final int actual = await new Observable<int>.fromIterable(<int>[1, 2, 3])
        .fold(4, (int prev, int val) => prev + val);

    await expectLater(actual, 10);
  });
}
