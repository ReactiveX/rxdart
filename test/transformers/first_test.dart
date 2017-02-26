import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.first', () async {
    final int actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).first;

    await expect(actual, 1);
  });
}
