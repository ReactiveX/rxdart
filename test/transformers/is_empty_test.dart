import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.isEmpty.populated', () async {
    final bool populated =
        await new Observable<int>.fromIterable(<int>[1, 2, 3]).isEmpty;

    await expectLater(populated, isFalse);
  });

  test('rx.Observable.isEmpty.empty', () async {
    final bool empty = await new Observable<int>.fromIterable(<int>[]).isEmpty;
    await expectLater(empty, isTrue);
  });
}
