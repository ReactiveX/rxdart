import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.contains', () async {
    final bool actual = await new Observable<int>.just(1).contains(1);

    expect(actual, true);
  });
}
