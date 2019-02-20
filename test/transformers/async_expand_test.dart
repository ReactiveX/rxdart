import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.asyncExpand', () async {
    const expected = [1, 2, 3];
    var count = 0;

    final observable = Observable.fromIterable(expected)
        .asyncExpand((value) => Observable.fromIterable([value]));

    observable.listen(expectAsync1((actual) {
      expect(actual, expected[count++]);
    }, count: expected.length));
  });
}
