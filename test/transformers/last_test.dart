import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.last', () async {
    final int actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).last;

    await expectLater(actual, 3);
  });
}
