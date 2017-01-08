import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart' as rx;

Stream<num> getDelayedStream<T>(int delay, num value) async* {
  final Completer<dynamic> completer = new Completer<dynamic>();

  new Timer(new Duration(milliseconds: delay), () => completer.complete());

  await completer.future;

  yield value;
  yield value + 1;
  yield value + 2;
}

void main() {
  test('rx.Observable.amb', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);
    int expected = 1;

    new rx.Observable<num>.amb(<Stream<num>>[
      first,
      second,
      last]
    ).listen(expectAsync1((num result) {
      // test to see if the combined output matches
      expect(result.compareTo(expected++), 0);
    }, count: 3));
  });

  test('rx.Observable.amb.asBroadcastStream', () async {
    final Stream<num> first = getDelayedStream(50, 1);
    final Stream<num> second = getDelayedStream(60, 2);
    final Stream<num> last = getDelayedStream(70, 3);

    Stream<num> observable = new rx.Observable<num>.amb(<Stream<num>>[
        first,
        second,
        last],
        asBroadcastStream: true
    );

    // listen twice on same stream
    observable.listen((_) {});
    observable.listen((_) {});
    // code should reach here
    expect(true, true);
  });
}