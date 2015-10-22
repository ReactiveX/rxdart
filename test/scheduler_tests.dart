library test.scheduler;

import 'dart:async';
import 'package:test/test.dart' as test;
import 'package:rxdart/rxdart.dart' as Rx;

void main() {
  test.test('Rx.Scheduler.schedule', () async {
    final Completer C = new Completer();
    
    Rx.Scheduler.asDefault.schedule(1, (Rx.Scheduler s, int x) => C.complete(x));
    
    test.expect(await C.future, 1);
  });
}