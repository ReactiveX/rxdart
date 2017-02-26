import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.forEach', () async {
    bool wasCalled = false;

    await new Observable<int>.just(1).forEach((_) {
      wasCalled = true;
    });

    await expect(wasCalled, isTrue);
  });
}
