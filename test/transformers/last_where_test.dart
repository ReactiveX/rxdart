import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.lastWhere', () async {
    final dynamic last =
        await new Observable<String>.fromIterable(const <String>['h', 'i'])
            .lastWhere((String element) => element.length == 1);

    await expectLater(last, 'i');
  });
}
