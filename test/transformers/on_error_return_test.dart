import '../test_utils.dart';
import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  const num expected = 0;

  test('rx.Observable.onErrorReturn', () async {
    observable(getErroneousStream())
        .onErrorReturn(0)
        .listen(expectAsync1((num result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.onErrorReturn.asBroadcastStream', () async {
    Stream<num> stream =
        observable(getErroneousStream()).onErrorReturn(0).asBroadcastStream();

    expect(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((num result) {
      expect(result, expected);
    }));

    stream.listen(expectAsync1((num result) {
      expect(result, expected);
    }));
  });

  test('rx.Observable.onErrorReturn.pause.resume', () async {
    StreamSubscription<num> subscription;

    subscription = observable(getErroneousStream())
        .onErrorReturn(0)
        .listen(expectAsync1((num result) {
      expect(result, expected);

      subscription.cancel();
    }));

    subscription.pause();
    subscription.resume();
  });
}
