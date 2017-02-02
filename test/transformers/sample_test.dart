import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 20), (int count) => count).take(5);
Stream<int> _getSampleStream() => new Stream<int>.periodic(
    const Duration(milliseconds: 35), (int count) => count).take(5);

void main() {
  test('rx.Observable.sample', () async {
    const List<int> expectedOutput = const <int>[0, 2, 4, 4, 4];
    int count = 0;

    new Observable<int>(_getStream())
        .sample(_getSampleStream())
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.sample.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .sample(_getSampleStream().asBroadcastStream());

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.sample.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .sample(_getSampleStream());

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.sample.pause.resume', () async {
    const List<int> expectedOutput = const <int>[0, 2, 4, 4, 4];
    int count = 0;
    StreamSubscription<int> subscription;

    subscription = new Observable<int>(_getStream())
        .sample(_getSampleStream())
        .listen(expectAsync1((int result) {
          expect(expectedOutput[count++], result);

          if (count == expectedOutput.length) {
            subscription.cancel();
          }
        }, count: expectedOutput.length));

    subscription.pause();
    subscription.resume();
  });
}
