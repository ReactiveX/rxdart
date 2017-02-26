import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  const num expected = 0;

  test('rx.Observable.onErrorReturn', () async {
    observable(new ErrorStream<num>(new Exception()))
        .onErrorReturn(0)
        .listen(expectAsync1((num result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.onErrorReturn.asBroadcastStream', () async {
    Stream<num> stream = observable(new ErrorStream<num>(new Exception()))
        .onErrorReturn(0)
        .asBroadcastStream();

    await expect(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((num result) {
      expect(result, expected);
    }));

    stream.listen(expectAsync1((num result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.onErrorReturn.pause.resume', () async {
    StreamSubscription<num> subscription;

    subscription = observable(new ErrorStream<num>(new Exception()))
        .onErrorReturn(0)
        .listen(expectAsync1((num result) {
      expect(result, expected);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}
