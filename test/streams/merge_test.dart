import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

List<Stream<int>> _getStreams() {
  var a = Stream.periodic(const Duration(milliseconds: 1), (count) => count)
          .take(3),
      b = Stream.fromIterable(const [1, 2, 3, 4]);

  return [a, b];
}

void main() {
  test('Rx.merge', () async {
    final stream = Rx.merge(_getStreams());

    await expectLater(stream, emitsInOrder(const <int>[1, 2, 3, 4, 0, 1, 2]));
  });

  test('Rx.merge.single.subscription', () async {
    final stream = Rx.merge(_getStreams());

    stream.listen(null);
    await expectLater(() => stream.listen(null), throwsA(isStateError));
  });

  test('Rx.merge.asBroadcastStream', () async {
    final stream = Rx.merge(_getStreams()).asBroadcastStream();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(stream.isBroadcast, isTrue);
  });

  test('Rx.merge.error.shouldThrowA', () async {
    final streamWithError =
        Rx.merge(_getStreams()..add(Stream<int>.error(Exception())));

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.merge.error.shouldThrowB', () {
    expect(() => Rx.merge<int>(null), throwsArgumentError);
  });

  test('Rx.merge.error.shouldThrowC', () {
    expect(() => Rx.merge<int>(const []), throwsArgumentError);
  });

  test('Rx.merge.error.shouldThrowD', () {
    expect(() => Rx.merge([Stream.value(1), null]), throwsArgumentError);
  });

  test('Rx.merge.pause.resume', () async {
    final first = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [1, 2, 3, 4][index]),
        second = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [5, 6, 7, 8][index]),
        last = Stream.periodic(const Duration(milliseconds: 10),
            (index) => const [9, 10, 11, 12][index]);

    StreamSubscription<num> subscription;
    // ignore: deprecated_member_use
    subscription = Rx.merge([first, second, last]).listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause(Future<Null>.delayed(const Duration(milliseconds: 80)));
  });
}
