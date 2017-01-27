import '../test_utils.dart';
import 'dart:async';

import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream<num> _getOtherStream() {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 250), () {
    controller.add(1);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.takeUntil', () async {
    new FakeAsync().run((FakeAsync fakeAsync) {
      const List<int> expectedOutput = const <int>[1, 2];
      int count = 0;

      observable(_getStream())
          .takeUntil(_getOtherStream())
          .listen(expectAsync1((int result) {
            expect(expectedOutput[count++], result);
          }, count: expectedOutput.length));

      fakeAsync.elapse(new Duration(minutes: 1));
    });
  });

  test('rx.Observable.takeUntil.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream())
        .takeUntil(_getOtherStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.takeUntil.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).takeUntil(_getOtherStream());

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.takeUntil.pause.resume', () async {
    new FakeAsync().run((FakeAsync fakeAsync) {
      StreamSubscription<int> subscription;
      const List<int> expectedOutput = const <int>[1, 2];
      int count = 0;

      subscription = observable(_getStream())
          .takeUntil(_getOtherStream())
          .listen(expectAsync1((int result) {
            expect(result, expectedOutput[count++]);

            if (count == expectedOutput.length) {
              subscription.cancel();
            }
          }, count: expectedOutput.length));

      subscription.pause();
      subscription.resume();
      fakeAsync.elapse(new Duration(minutes: 1));
    });
  });
}
