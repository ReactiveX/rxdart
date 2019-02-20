import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.mapTo', () async {
    await expectLater(Observable.range(1, 4).mapTo(true),
        emitsInOrder(<dynamic>[true, true, true, true, emitsDone]));
  });

  test('rx.Observable.mapTo.shouldThrow', () async {
    await expectLater(
        Observable.range(1, 4)
            .concatWith([ErrorStream<int>(Error())]).mapTo(true),
        emitsInOrder(<dynamic>[
          true,
          true,
          true,
          true,
          emitsError(TypeMatcher<Error>()),
          emitsDone
        ]));
  });

  test('rx.Observable.mapTo.reusable', () async {
    final transformer = MapToStreamTransformer<int, bool>(true);
    final observable = Observable.range(1, 4).asBroadcastStream();

    observable.transform(transformer).listen(null);
    observable.transform(transformer).listen(null);

    await expectLater(true, true);
  });

  test('rx.Observable.mapTo.pause.resume', () async {
    StreamSubscription<bool> subscription;
    final stream = Observable.just(1).mapTo(true);

    subscription = stream.listen(expectAsync1((value) {
      expect(value, isTrue);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
