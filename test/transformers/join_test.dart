import 'package:test/test.dart';

void main() {
  test('rx.Observable.join', () async {
    final joined = await Stream.fromIterable(const ['h', 'i']).join('+');

    await expectLater(joined, 'h+i');
  });
}
