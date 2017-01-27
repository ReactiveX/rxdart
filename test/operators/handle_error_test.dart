import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.handleError', () async {
    final ArgumentError expected = new ArgumentError();

    Stream<num> obs = observable(getErroneousStream()).handleError((_) {
      throw expected;
    });

    obs.listen((_) {}, onError: expectAsync2((dynamic e, dynamic s) {
      expect(e, isArgumentError);
      expect(obs is Observable, isTrue);
    }));
  });
}
