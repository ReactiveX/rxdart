library rx.test.subject.behaviour_subject;

import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.BehaviourSubject', () async {
    final StreamController<int> subject = new BehaviourSubject<int>.broadcast();

    subject.add(1);

    subject.stream.listen(expectAsync1((int result) {
      expect(result, 1);
    }));
  });

  test('rx.BehaviourSubject.multiSubscribe', () async {
    final StreamController<int> subject = new BehaviourSubject<int>.broadcast();

    subject.add(1);
    subject.add(2);
    subject.add(3);

    subject.stream.listen(expectAsync1((int result) {
      expect(result, 3);
    }));

    subject.stream.listen(expectAsync1((int result) {
      expect(result, 3);
    }));

    subject.stream.listen(expectAsync1((int result) {
      expect(result, 3);
    }));
  });
}