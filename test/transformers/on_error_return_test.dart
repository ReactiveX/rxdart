import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  const num expected = 0;

  test('rx.Observable.onErrorReturn', () async {
    new Observable<num>(new ErrorStream<num>(new Exception()))
        .onErrorReturn(0)
        .listen(expectAsync1((num result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.onErrorReturn.asBroadcastStream', () async {
    Stream<num> stream =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .onErrorReturn(0)
            .asBroadcastStream();

    await expectLater(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((num result) {
      expect(result, expected);
    }));

    stream.listen(expectAsync1((num result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.onErrorReturn.pause.resume', () async {
    StreamSubscription<num> subscription;

    subscription = new Observable<num>(new ErrorStream<num>(new Exception()))
        .onErrorReturn(0)
        .listen(expectAsync1((num result) {
      expect(result, expected);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}
