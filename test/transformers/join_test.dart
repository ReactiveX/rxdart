import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.join', () async {
    final String joined =
        await new Observable<String>.fromIterable(<String>['h', 'i']).join('+');

    await expectLater(joined, 'h+i');
  });
}
