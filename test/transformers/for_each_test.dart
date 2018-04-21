import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.forEach', () async {
    bool wasCalled = false;

    await new Observable<int>.just(1).forEach((_) {
      wasCalled = true;
    });

    await expectLater(wasCalled, isTrue);
  });
}
