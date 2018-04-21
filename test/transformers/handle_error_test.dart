import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.handleError', () async {
    final ArgumentError expected = new ArgumentError();

    Stream<num> obs = new Observable<num>(new ErrorStream<num>(new Exception()))
        .handleError((dynamic _) {
      throw expected;
    });

    obs.listen((_) {}, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
      expect(obs is Observable, isTrue);
    }));
  });
}
