import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.isEmpty.populated', () async {
    final populated =
        await new Observable.fromIterable(const [1, 2, 3]).isEmpty;

    await expectLater(populated, isFalse);
  });

  test('rx.Observable.isEmpty.empty', () async {
    final empty = await new Observable.fromIterable(const <int>[]).isEmpty;
    await expectLater(empty, isTrue);
  });
}
