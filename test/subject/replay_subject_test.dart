import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.BehaviourSubject.multiSubscribe', () async {
    final StreamController<int> subject = new ReplaySubject<int>.broadcast();
    int countA = 0;
    int countB = 0;
    int countC = 0;

    subject.add(1);
    subject.add(2);
    subject.add(3);

    subject.stream.listen(expectAsync1((int result) {
      countA++;
      expect(result, countA);
    }, count: 4));

    subject.stream.listen(expectAsync1((int result) {
      countB++;
      expect(result, countB);
    }, count: 4));

    subject.stream.listen(expectAsync1((int result) {
      countC++;
      expect(result, countC);

      if (countC == 4) subject.close();
    }, count: 4));

    subject.add(4);
  });
}
