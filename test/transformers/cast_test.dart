import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/transformers/cast.dart';
import 'package:rxdart/src/utils/type_token.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.Observable.cast', () async {
    final Observable<num> observable =
        new Observable<num>.fromIterable(<int>[1, 2, 3]);

    await expect(observable.cast(kInt).map((int i) => i.isEven),
        emitsInOrder(<dynamic>[false, true, false, emitsDone]));
  });

  group('CastStreamTransformer', () {
    test('casts all items to a specific type', () async {
      final Stream<num> stream = new Stream<num>.fromIterable(<int>[1, 2, 3]);

      await expect(
          stream
              .transform(
                  new CastStreamTransformer<num, int>(new TypeToken<int>()))
              .map((int i) => i.isEven),
          emitsInOrder(<dynamic>[false, true, false, emitsDone]));
    });

    test('emits an error if the cast is invalid', () async {
      final Stream<num> stream = new Stream<num>.fromIterable(<num>[1.2, 2]);

      await expect(
          stream.transform(
              new CastStreamTransformer<num, int>(new TypeToken<int>())),
          emitsInOrder(<dynamic>[
            emitsError(new isInstanceOf<CastError>()),
            2,
            emitsDone
          ]));
    });

    test('supports pause and resume', () async {
      StreamSubscription<int> subscription;
      Stream<int> stream = new Stream<num>.fromIterable(<int>[1])
          .transform(new CastStreamTransformer<num, int>(kInt));

      subscription = stream.listen(expectAsync1((int value) {
        expect(value, 1);

        subscription.cancel();
      }, count: 1));

      subscription.pause();
      subscription.resume();
    });

    test('throws when cast fails', () async {
      new Observable<int>.just(1)
          .cast(const TypeToken<String>())
          .listen(null, onError: (e, s) => expect(e, isCastError));
    });
  });
}

/// A matcher for CastErrors.
const Matcher isCastError = const _CastError();

class _CastError extends TypeMatcher {
  const _CastError() : super("CastError");
  bool matches(item, Map matchState) => item is CastError;
}
