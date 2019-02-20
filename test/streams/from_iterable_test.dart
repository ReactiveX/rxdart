import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.fromIterable', () async {
    const value = 1;

    final observable = Observable.fromIterable([value]);

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });
}
