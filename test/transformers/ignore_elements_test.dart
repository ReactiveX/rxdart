import '../test_utils.dart';
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
  test('rx.Observable.ignoreElements', () async {
    bool hasReceivedEvent = false;

    new Observable<int>(_getStream()).ignoreElements().listen((_) {
      hasReceivedEvent = true;
    },
        onDone: expectAsync0(() {
          expect(hasReceivedEvent, isFalse);
        }, count: 1));
  });

  test('rx.Observable.ignoreElements.asBroadcastStream', () async {
    Stream<int> stream =
        new Observable<int>(_getStream().asBroadcastStream()).ignoreElements();

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.ignoreElements.pause.resume', () async {
    bool hasReceivedEvent = false;

    new Observable<int>(_getStream()).ignoreElements().listen((_) {
      hasReceivedEvent = true;
    },
        onDone: expectAsync0(() {
          expect(hasReceivedEvent, isFalse);
        }, count: 1))
      ..pause()
      ..resume();
  });

  test('rx.Observable.ignoreElements.error.shouldThrow', () async {
    Stream<num> observableWithError =
        new Observable<num>(getErroneousStream()).ignoreElements();

    observableWithError.listen(null,
        onError: expectAsync2((dynamic e, dynamic s) {
          expect(e, isException);
        }, count: 1));
  });
}
