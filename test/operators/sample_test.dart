import '../test_utils.dart';
import 'dart:async';

import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 20), (int count) => count).take(5);
Stream<int> _getSampleStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 35), (int count) => count).take(5);

void main() {
  test('rx.Observable.sample', () async {
    new FakeAsync().run((FakeAsync fakeAsync) {
      const List<int> expectedOutput = const <int>[0, 2, 4, 4, 4];
      int count = 0;

      observable(_getStream())
          .sample(_getSampleStream())
          .listen(expectAsync1((int result) {
            expect(expectedOutput[count++], result);
          }, count: expectedOutput.length));

      fakeAsync.elapse(new Duration(minutes: 1));
    });
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    Stream<int> stream = observable(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.sample.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).sample(_getSampleStream());

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.sample.pause.resume', () async {
    new FakeAsync().run((FakeAsync fakeAsync) {
      const List<int> expectedOutput = const <int>[0, 2, 4, 4, 4];
      int count = 0;
      StreamSubscription<int> subscription;

      subscription = observable(_getStream())
          .sample(_getSampleStream())
          .listen(expectAsync1((int result) {
            expect(expectedOutput[count++], result);

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
