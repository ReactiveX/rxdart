import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.reduce', () async {
    final int actual = await new Observable<int>.fromIterable(<int>[1, 2, 3])
        .reduce((int prev, int val) => prev + val);

    await expectLater(actual, 6);
  });
}
