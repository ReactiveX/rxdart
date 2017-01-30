import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.drain', () async {
    final int expected = 2;

    final int actual = await new Observable<int>.just(1).drain(expected);

    expect(actual, expected);
  });
}
