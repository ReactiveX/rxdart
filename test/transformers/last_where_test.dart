import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.lastWhere', () async {
    final String last =
        await new Observable<String>.fromIterable(<String>['h', 'i'])
            .lastWhere((String element) => element.length == 1);

    await expect(last, 'i');
  });
}
