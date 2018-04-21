import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.first', () async {
    final int actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).first;

    await expectLater(actual, 1);
  });
}
