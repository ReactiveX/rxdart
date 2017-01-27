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

void main() {
  test('rx.Observable.throttle', () async {
    new FakeAsync().run((FakeAsync fakeaAsync) {
      const List<int> expectedOutput = const <int>[1, 4];
      int count = 0;

      observable(_getStream())
          .throttle(const Duration(milliseconds: 250))
          .listen(expectAsync1((int result) {
            expect(result, expectedOutput[count++]);
          }, count: 2));

      fakeaAsync.elapse(new Duration(minutes: 1));
    });
  });

  test('rx.Observable.throttle.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream())
        .throttle(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.throttle.error.shouldThrow', () async {
    Stream<num> observableWithError = observable(getErroneousStream())
        .throttle(const Duration(milliseconds: 200));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.throttle.pause.resume', () async {
    new FakeAsync().run((FakeAsync fakeaAsync) {
      StreamSubscription<int> subscription;
      const List<int> expectedOutput = const <int>[1, 4];
      int count = 0;

      subscription = observable(_getStream())
          .throttle(const Duration(milliseconds: 250))
          .listen(expectAsync1((int result) {
            expect(result, expectedOutput[count++]);

            if (count == expectedOutput.length) {
              subscription.cancel();
            }
          }, count: expectedOutput.length));

      subscription.pause();
      subscription.resume();
      fakeaAsync.elapse(new Duration(minutes: 1));
    });
  });
}
