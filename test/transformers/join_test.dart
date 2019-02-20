import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.join', () async {
    final joined = await Observable.fromIterable(const ['h', 'i']).join('+');

    await expectLater(joined, 'h+i');
  });
}
