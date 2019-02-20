import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.periodic', () async {
    const value = 1;

    final observable =
        Observable.periodic(Duration(milliseconds: 1), (_) => value).take(1);

    observable.listen(expectAsync1((actual) {
      expect(actual, value);
    }, count: 1));
  });
}
