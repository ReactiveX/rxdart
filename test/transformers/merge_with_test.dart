import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.mergeWith', () async {
    final Observable<int> delayedStream =
        new Observable<int>.timer(1, new Duration(milliseconds: 10));
    final Observable<int> immediateStream = new Observable<int>.just(2);
    final List<int> expected = <int>[2, 1];
    int count = 0;

    new Observable<int>(delayedStream).mergeWith(
        <Observable<int>>[immediateStream]).listen(expectAsync1((int result) {
      expect(result, expected[count++]);
    }, count: expected.length));
  });
}
