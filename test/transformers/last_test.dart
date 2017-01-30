import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.last', () async {
    final int actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).last;

    expect(actual, 3);
  });
}
