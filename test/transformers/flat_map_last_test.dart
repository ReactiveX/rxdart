import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('Rx.flatMapLast', () async {
    await expectLater(
      _getStream().flatMapLast(_getOtherStream),
      emitsInOrder(<dynamic>['a-1', 'b-1', 'b-2', emitsDone]),
    );
  });

  test('Rx.flatMapLast.asBroadcastStream', () async {
    final stream =
        _getStream().asBroadcastStream().flatMapLast(_getOtherStream);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('Rx.flatMapLast.error.shouldThrowA', () async {
    final streamWithError =
        Stream<String>.error(Exception()).flatMapLast(_getOtherStream);

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.flatMapLast.error.shouldThrowB', () async {
    final streamWithError = Stream.value(1).flatMapLast(
        (_) => Stream<void>.error(Exception('Catch me if you can!')));

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.flatMap.error.shouldThrowC', () async {
    final streamWithError =
        Stream.value(1).flatMapLast<void>((_) => throw Exception('oh noes!'));

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.flatMapLast.pause.resume', () async {
    late StreamSubscription<int> subscription;
    final stream = Stream.value(0).flatMapLast((_) => Stream.value(1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('Rx.flatMapLast.chains', () {
    expect(
      Stream.value(1)
          .flatMapLast((a) => Stream.value(a + 2))
          .flatMapLast((b) => Stream.value(b * 3)),
      emitsInOrder(<dynamic>[9, emitsDone]),
    );
  });

  test('Rx.flatMapLast accidental broadcast', () async {
    final controller = StreamController<int>();

    final stream = controller.stream.flatMapLast((_) => Stream<int>.empty());

    stream.listen(null);
    expect(() => stream.listen(null), throwsStateError);

    controller.add(1);
  });

  test('Rx.flatMapLast.cancel', () {
    _getStream()
        .flatMapLast(_getOtherStream)
        .listen(expectAsync1((data) {}, count: 0))
        .cancel();
  }, timeout: const Timeout(Duration(milliseconds: 200)));
}

Stream<String> _getStream() => Stream.fromFutures([
      Future.delayed(Duration(milliseconds: 1000), () => 'a'),
      Future.delayed(Duration(milliseconds: 2000), () => 'b')
    ]);

Stream<String> _getOtherStream(String value) => Stream.fromFutures([
      Future.delayed(Duration(milliseconds: 300), () => '$value-1'),
      Future.delayed(Duration(milliseconds: 1500), () => '$value-2'),
    ]);
