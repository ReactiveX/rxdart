import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.elementAt', () async {
    final int actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3, 4, 5])
            .elementAt(0);

    await expectLater(actual, 1);
  });
}
