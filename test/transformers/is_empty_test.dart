import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.isEmpty.populated', () async {
    final bool populated =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).isEmpty;

    await expect(populated, isFalse);
  });

  test('rx.Observable.isEmpty.empty', () async {
    final bool empty = await new Observable<int>.fromIterable(<int>[]).isEmpty;
    await expect(empty, isTrue);
  });
}
