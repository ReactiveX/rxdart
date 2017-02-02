import 'dart:async';

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

Stream<num> _getOtherStream(num value) {
  StreamController<num> controller = new StreamController<num>();

  new Timer(const Duration(milliseconds: 100), () => controller.add(value + 1));
  new Timer(const Duration(milliseconds: 200), () => controller.add(value + 2));
  new Timer(const Duration(milliseconds: 300), () => controller.add(value + 3));
  new Timer(const Duration(milliseconds: 400), () {
    controller.add(value + 4);
    controller.close();
  });

  return controller.stream;
}

void main() {
  test('rx.Observable.flatMap', () async {
    const List<int> expectedOutput = const <int>[
      2,
      3,
      3,
      4,
      4,
      4,
      5,
      5,
      5,
      5,
      6,
      6,
      6,
      7,
      7,
      8
    ];
    int count = 0;

    new Observable<int>(_getStream())
        .flatMap(_getOtherStream)
        .listen(expectAsync1((num result) {
          expect(expectedOutput[count++], result);
        }, count: expectedOutput.length));
  });

  test('rx.Observable.flatMap.asBroadcastStream', () async {
    Stream<num> stream = new Observable<int>(_getStream().asBroadcastStream())
        .flatMap(_getOtherStream);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.flatMap.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .flatMap(_getOtherStream);

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  test('rx.Observable.flatMap.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream =
        new Observable<int>.just(0).flatMap((_) => new Observable<int>.just(1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 1);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
