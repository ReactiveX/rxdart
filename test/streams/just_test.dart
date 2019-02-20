import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.just', () async {
    const value = 1;

    final observable = Observable.just(value);

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });
}
