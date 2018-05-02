import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.zipWith', () async {
    new Observable<int>(new Observable<int>.just(1))
        .zipWith(new Observable<int>.just(2), (int one, int two) => one + two)
        .listen(expectAsync1((int result) {
          expect(result, 3);
        }, count: 1));
  });
}
