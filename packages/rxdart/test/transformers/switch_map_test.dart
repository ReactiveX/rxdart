import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import '../utils.dart';

Stream<int> _getStream() {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 10), () => controller.add(1));
  Timer(const Duration(milliseconds: 20), () => controller.add(2));
  Timer(const Duration(milliseconds: 30), () => controller.add(3));
  Timer(const Duration(milliseconds: 40), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> _getOtherStream(int value) {
  final controller = StreamController<int>();

  Timer(const Duration(milliseconds: 15), () => controller.add(value + 1));
  Timer(const Duration(milliseconds: 25), () => controller.add(value + 2));
  Timer(const Duration(milliseconds: 35), () => controller.add(value + 3));
  Timer(const Duration(milliseconds: 45), () {
    controller.add(value + 4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> range() =>
    Stream.fromIterable(const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

void main() {
  test('Rx.switchMap', () async {
    const expectedOutput = [5, 6, 7, 8];
    var count = 0;

    _getStream().switchMap(_getOtherStream).listen(expectAsync1((result) {
          expect(result, expectedOutput[count++]);
        }, count: expectedOutput.length));
  });

  test('Rx.switchMap.reusable', () async {
    final transformer = SwitchMapStreamTransformer<int, int>(_getOtherStream);
    const expectedOutput = [5, 6, 7, 8];
    var countA = 0, countB = 0;

    _getStream().transform(transformer).listen(expectAsync1((result) {
          expect(result, expectedOutput[countA++]);
        }, count: expectedOutput.length));

    _getStream().transform(transformer).listen(expectAsync1((result) {
          expect(result, expectedOutput[countB++]);
        }, count: expectedOutput.length));
  });

  test('Rx.switchMap.asBroadcastStream', () async {
    final stream = _getStream().asBroadcastStream().switchMap(_getOtherStream);

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('Rx.switchMap.error.shouldThrowA', () async {
    final streamWithError =
        Stream<int>.error(Exception()).switchMap(_getOtherStream);

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.switchMap.error.shouldThrowB', () async {
    final streamWithError = Stream.value(1).switchMap(
        (_) => Stream<void>.error(Exception('Catch me if you can!')));

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.switchMap.error.shouldThrowC', () async {
    final streamWithError = Stream.value(1).switchMap<void>((_) {
      throw Exception('oh noes!');
    });

    streamWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('Rx.switchMap.pause.resume', () async {
    late StreamSubscription<int> subscription;
    final stream = Stream.value(0).switchMap((_) => Stream.value(1));

    subscription = stream.listen(expectAsync1((value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });

  test('Rx.switchMap stream close after switch', () async {
    final controller = StreamController<int>();
    final list = controller.stream
        .switchMap((it) => Stream.fromIterable([it, it]))
        .toList();

    controller.add(1);
    await Future<void>.delayed(Duration(microseconds: 1));
    controller.add(2);

    await controller.close();
    expect(await list, [1, 1, 2, 2]);
  });

  test('Rx.switchMap accidental broadcast', () async {
    final controller = StreamController<int>();

    final stream = controller.stream.switchMap((_) => Stream<int>.empty());

    stream.listen(null);
    expect(() => stream.listen(null), throwsStateError);

    controller.add(1);
  });

  test('Rx.switchMap closes after the last inner Stream closed - issue/511',
      () async {
    final outer = StreamController<bool>();
    final inner = BehaviorSubject.seeded(false);
    final stream = outer.stream.switchMap((_) => inner.stream);

    expect(stream, emitsThrough(emitsDone));

    outer.add(true);
    await Future<void>.delayed(Duration.zero);
    await inner.close();
    await outer.close();
  });

  test('Rx.switchMap every subscription triggers a listen on the root Stream',
      () async {
    var count = 0;
    final controller = StreamController<bool>.broadcast();
    final root =
        OnSubscriptionTriggerableStream(controller.stream, () => count++);
    final stream = root.switchMap((event) => Stream.value(event));

    stream.listen((event) {});
    stream.listen((event) {});

    expect(count, 2);

    await controller.close();
  });

  test('Rx.switchMap.nullable', () {
    nullableTest<String?>(
      (s) => s.switchMap((v) => Stream.value(v)),
    );
  });

  test(
    'Rx.switchMap pauses subscription when cancelling inner subscription, then resume',
    () async {
      var isController1Cancelled = false;
      final cancelCompleter1 = Completer<void>.sync();
      final controller1 = StreamController<int>()
        ..add(0)
        ..add(1)
        ..onCancel = () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await cancelCompleter1.future;
          isController1Cancelled = true;
        };

      final controller2 = StreamController<int>()
        ..add(2)
        ..add(3)
        ..onListen = () {
          expect(
            isController1Cancelled,
            true,
            reason:
                'controller1 should be cancelled before controller2 is listened to',
          );
        };

      final controller = StreamController<StreamController<int>>()
        ..add(controller1);
      final stream = controller.stream.switchMap((c) => c.stream);

      var expected = 0;
      stream.listen(
        expectAsync1(
          (v) async {
            expect(v, expected++);

            if (v == 1) {
              // switch to controller2.stream
              controller.add(controller2);

              await Future<void>.delayed(const Duration(milliseconds: 10));
              cancelCompleter1.complete(null);
            }
          },
          count: 4,
        ),
      );
    },
  );

  test('Rx.switchMap forwards errors from the cancel()', () {
    var isController1Cancelled = false;

    final controller1 = StreamController<int>()
      ..add(0)
      ..add(1)
      ..onCancel = () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        isController1Cancelled = true;
        throw Exception('cancel error');
      };

    final controller2 = StreamController<int>()
      ..add(2)
      ..add(3)
      ..onListen = () {
        expect(
          isController1Cancelled,
          true,
          reason:
              'controller1 should be cancelled before controller2 is listened to',
        );
      };

    final controller = StreamController<StreamController<int>>()
      ..add(controller1);
    final stream = controller.stream.switchMap((c) => c.stream);

    var expected = 0;
    stream.listen(
      expectAsync1(
        (v) async {
          expect(v, expected++);

          if (v == 1) {
            // switch to controller2.stream
            controller.add(controller2);
          }
        },
        count: 4,
      ),
      onError: expectAsync1(
        (Object error) => expect(error, isException),
        count: 1,
      ),
    );
  });

  test(
    'Rx.switchMap pauses the next inner StreamSubscription when pausing while cancelling the previous inner Stream',
    () {
      var isController1Cancelled = false;
      final cancelCompleter1 = Completer<void>.sync();
      final controller1 = StreamController<int>()
        ..add(0)
        ..add(1)
        ..onCancel = () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await cancelCompleter1.future;
          isController1Cancelled = true;
        };

      final controller2 = StreamController<int>()
        ..add(2)
        ..add(3)
        ..onListen = () {
          expect(
            isController1Cancelled,
            true,
            reason:
                'controller1 should be cancelled before controller2 is listened to',
          );
        };

      final controller = StreamController<StreamController<int>>()
        ..add(controller1);
      final stream = controller.stream.switchMap((c) => c.stream);

      var expected = 0;
      late StreamSubscription<void> subscription;
      subscription = stream.listen(
        expectAsync1(
          (v) async {
            expect(v, expected++);

            if (v == 1) {
              // switch to controller2.stream
              controller.add(controller2);

              await Future<void>.delayed(const Duration(milliseconds: 10));

              // pauses the subscription while cancelling the controller1
              subscription.pause();

              // let the cancellation of controller1 complete
              cancelCompleter1.complete(null);

              // make sure the controller2.stream is added to the controller
              await pumpEventQueue();

              // controller2.stream should be paused
              expect(controller2.isPaused, true);

              // resume the subscription to continue the rest of the stream
              subscription.resume();
            }
          },
          count: 4,
        ),
      );
    },
  );
}

class OnSubscriptionTriggerableStream<T> extends Stream<T> {
  final Stream<T> inner;
  final void Function() onSubscribe;

  OnSubscriptionTriggerableStream(this.inner, this.onSubscribe);

  @override
  bool get isBroadcast => inner.isBroadcast;

  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    onSubscribe();
    return inner.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
