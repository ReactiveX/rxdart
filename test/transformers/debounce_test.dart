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

void main() {
  test('rx.Observable.debounce', () async {
    new Observable<int>(_getStream())
        .debounce(const Duration(milliseconds: 200))
        .listen(expectAsync1((int result) {
          expect(result, 4);
        }, count: 1));
  });

  test('rx.Observable.debounce.reusable', () async {
    final DebounceStreamTransformer<int> transformer =
        new DebounceStreamTransformer<int>(const Duration(milliseconds: 200));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, 4);
        }, count: 1));

    new Observable<int>(_getStream())
        .transform(transformer)
        .listen(expectAsync1((int result) {
          expect(result, 4);
        }, count: 1));
  });

  test('rx.Observable.debounce.asBroadcastStream', () async {
    Stream<int> stream = new Observable<int>(_getStream().asBroadcastStream())
        .debounce(const Duration(milliseconds: 200));

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    await expect(true, true);
  });

  test('rx.Observable.debounce.error.shouldThrowA', () async {
    Stream<num> observableWithError =
        new Observable<num>(new ErrorStream<num>(new Exception()))
            .debounce(const Duration(milliseconds: 200));

    observableWithError.listen(null, onError: (dynamic e, dynamic s) {
      expect(e, isException);
    });
  });

  /// Should also throw if the current [Zone] is unable to install a [Timer]
  test('rx.Observable.debounce.error.shouldThrowB', () async {
    runZoned(() {
      Stream<num> observableWithError = new Observable<int>.just(1)
          .debounce(const Duration(milliseconds: 200));

      observableWithError.listen(null, onError: (dynamic e, dynamic s) {
        expect(e, isException);
      });
    },
        zoneSpecification: new ZoneSpecification(
            createTimer: (Zone self, ZoneDelegate parent, Zone zone,
                    Duration duration, void f()) =>
                throw new Exception('Zone createTimer error')));
  });

  test('rx.Observable.debounce.pause.resume', () async {
    StreamSubscription<int> subscription;
    Observable<int> stream = new Observable<int>.fromIterable(<int>[1, 2, 3])
        .debounce(new Duration(milliseconds: 1));

    subscription = stream.listen(expectAsync1((int value) {
      expect(value, 3);

      subscription.cancel();
    }, count: 1));

    subscription.pause();
    subscription.resume();
  });
}
