import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.every', () async {
    final bool actual = await new Observable<int>.fromIterable(<int>[1, 2, 3])
        .every((int val) => val == 1);

    expect(actual, isFalse);
  });
}
