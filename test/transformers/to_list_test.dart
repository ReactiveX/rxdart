import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.toList', () async {
    final List<int> actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).toList();
    final List<int> expected = <int>[1, 2, 3];

    expect(actual, expected);
  });
}
