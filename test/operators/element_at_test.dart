import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.elementAt', () async {
    final int actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3, 4, 5])
            .elementAt(0);

    expect(actual, 1);
  });
}
