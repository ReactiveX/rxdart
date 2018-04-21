import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.toSet', () async {
    final Set<int> actual =
        await new Observable<int>.fromIterable(<int>[1, 2, 2]).toSet();
    final Set<int> expected = new Set<int>()..add(1)..add(2);

    await expectLater(actual, expected);
  });
}
