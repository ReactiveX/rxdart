import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.every', () async {
    final dynamic actual =
        await Observable<int>.just(1).firstWhere((int val) => val == 1);

    await expectLater(actual, 1);
  });
}
