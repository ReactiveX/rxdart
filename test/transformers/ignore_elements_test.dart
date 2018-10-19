import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() {
  final controller = new StreamController<int>();

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
    var hasReceivedEvent = false;

    new Observable(_getStream()).ignoreElements().listen((_) {
      hasReceivedEvent = true;
    },
        onDone: expectAsync0(() {
          expect(hasReceivedEvent, isFalse);
        }, count: 1));
  });

  test('rx.Observable.ignoreElements.reusable', () async {
    final transformer = new IgnoreElementsStreamTransformer<int>();
    var hasReceivedEvent = false;

    new Observable(_getStream()).transform(transformer).listen((_) {
      hasReceivedEvent = true;
    },
        onDone: expectAsync0(() {
          expect(hasReceivedEvent, isFalse);
        }, count: 1));

    new Observable(_getStream()).transform(transformer).listen((_) {
      hasReceivedEvent = true;
    },
        onDone: expectAsync0(() {
          expect(hasReceivedEvent, isFalse);
        }, count: 1));
  });

  test('rx.Observable.ignoreElements.asBroadcastStream', () async {
    final stream =
        new Observable(_getStream().asBroadcastStream()).ignoreElements();

    // listen twice on same stream
    stream.listen(null);
    stream.listen(null);
    // code should reach here
    await expectLater(true, true);
  });

  test('rx.Observable.ignoreElements.pause.resume', () async {
    var hasReceivedEvent = false;

    new Observable(_getStream()).ignoreElements().listen((_) {
      hasReceivedEvent = true;
    },
        onDone: expectAsync0(() {
          expect(hasReceivedEvent, isFalse);
        }, count: 1))
      ..pause()
      ..resume();
  });

  test('rx.Observable.ignoreElements.error.shouldThrow', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception())).ignoreElements();

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
          expect(e, isException);
        }, count: 1));
  });
}
