import 'package:test/test.dart';

import 'package:rxdart/src/transformers/on_done_resume.dart';

Stream<int> _initStream() => Stream.fromIterable([0, 1, 2]);

Stream<int> _onDoneStream() => Stream.fromIterable(([3, 3]));

void main() {
  test('Rx.onDoneResume', () {
    expectLater(_initStream().onDoneResume(() => _onDoneStream()),
        emitsInOrder(<dynamic>[0, 1, 2, 3, 3, emitsDone]));
  });
}
