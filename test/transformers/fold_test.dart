import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.fold', () async {
    final int actual = await new Observable<int>.fromIterable(<int>[1, 2, 3])
        .fold(4, (int prev, int val) => prev + val);

    expect(actual, 10);
  });
}
