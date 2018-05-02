import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.contains', () async {
    final bool actual = await new Observable<int>.just(1).contains(1);

    await expectLater(actual, true);
  });
}
