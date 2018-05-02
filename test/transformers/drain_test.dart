import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.drain', () async {
    final int expected = 2;

    final int actual = await new Observable<int>.just(1).drain(expected);

    await expectLater(actual, expected);
  });
}
