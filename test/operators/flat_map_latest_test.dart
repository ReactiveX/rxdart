import '../test_utils.dart';
import 'dart:async';

import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<int> _getStream() {
  StreamController<int> controller = new StreamController<int>();

  new Timer(const Duration(milliseconds: 10), () => controller.add(1));
  new Timer(const Duration(milliseconds: 20), () => controller.add(2));
  new Timer(const Duration(milliseconds: 30), () => controller.add(3));
  new Timer(const Duration(milliseconds: 40), () {
    controller.add(4);
    controller.close();
  });

  return controller.stream;
}

Stream<num> _getOtherStream(num value) {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 15), () => controller.add(value + 1));
  new Timer(const Duration(milliseconds: 25), () => controller.add(value + 2));
  new Timer(const Duration(milliseconds: 35), () => controller.add(value + 3));
  new Timer(const Duration(milliseconds: 45), () {
    controller.add(value + 4);
    controller.close();
  });

  return controller.stream;
}

Stream<int> range() =>
    new Stream<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

void main() {
  test('rx.Observable.flatMapLatest', () async {
    new FakeAsync().run((FakeAsync fakeAsync) {
      const List<int> expectedOutput = const <int>[5, 6, 7, 8];
      int count = 0;

      observable(_getStream())
          .flatMapLatest(_getOtherStream)
          .listen(expectAsync1((num result) {
        expect(result, expectedOutput[count++]);
      }, count: expectedOutput.length));

      fakeAsync.elapse(new Duration(milliseconds: 1000));
    });
  });

  test('rx.Observable.flatMapLatest.asBroadcastStream', () async {
    Stream<num> stream = observable(_getStream().asBroadcastStream())
        .flatMapLatest(_getOtherStream);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.flatMapLatest.error.shouldThrow', () async {
    Stream<num> observableWithError =
        observable(getErroneousStream()).flatMapLatest(_getOtherStream);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.flatMapLatest.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = observable(new Observable<int>.just(0))
        .flatMapLatest((_) => new Observable<int>.just(1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
