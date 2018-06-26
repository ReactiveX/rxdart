import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

typedef Future<Null> AsyncVoidCallBack();

void main() {
  group('BehaviorSubject', () {
    test('emits the most recently emitted item to every subscriber', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
    });

    test(
        'emits the most recently emitted item to every subscriber that subscribe to the subject directly',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject, emits(3));
      await expectLater(subject, emits(3));
      await expectLater(subject, emits(3));
    });

    test('can synchronously get the latest value', () async {
      // ignore: close_sinks
      final BehaviorSubject<int> subject = new BehaviorSubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expectLater(subject.value, 3);
    });

    test('emits the seed item if no new items have been emitted', () async {
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(seedValue: 1);

      await expectLater(subject.stream, emits(1));
      await expectLater(subject.stream, emits(1));
      await expectLater(subject.stream, emits(1));
    });

    test('can synchronously get the initial value', () {
      // ignore: close_sinks
      final BehaviorSubject<int> subject =
          new BehaviorSubject<int>(seedValue: 1);

      expect(subject.value, 1);
    });

    test('emits done event to listeners when the subject is closed', () async {
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(subject.isClosed, isFalse);

      subject.add(1);
      scheduleMicrotask(() => subject.close());

      await expectLater(subject.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(subject.isClosed, isTrue);
    });

    test('emits error events to subscribers', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      scheduleMicrotask(() => subject.addError(new Exception()));

      await expectLater(subject.stream, emitsError(isException));
    });

    test('replays the previously emitted items from addStream', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
    });

    test('allows items to be added once addStream is complete', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await subject.addStream(new Stream<int>.fromIterable(<int>[1, 2]));
      subject.add(3);

      await expectLater(subject.stream, emits(3));
    });

    test('allows items to be added once addStream is completes with an error',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(
          subject.addStream(new ErrorStream<int>(new Exception()),
              cancelOnError: true),
          throwsException);

      subject.add(1);

      await expectLater(subject.stream, emits(1));
    });

    test('does not allow events to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expectLater(() => subject.add(1), throwsStateError);
    });

    test('does not allow errors to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expectLater(() => subject.addError(new Error()), throwsStateError);
    });

    test('does not allow subject to be closed when addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expectLater(() => subject.close(), throwsStateError);
    });

    test(
        'does not allow addStream to add items when previous addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expectLater(
          () => subject.addStream(new Stream<int>.fromIterable(<int>[1])),
          throwsStateError);
    });

    test('returns onListen callback set in constructor', () async {
      final ControllerCallback testOnListen = () {};
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(onListen: testOnListen);

      await expectLater(subject.onListen, testOnListen);
    });

    test('sets onListen callback', () async {
      final ControllerCallback testOnListen = () {};
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(subject.onListen, isNull);

      subject.onListen = testOnListen;

      await expectLater(subject.onListen, testOnListen);
    });

    test('returns onCancel callback set in constructor', () async {
      final AsyncVoidCallBack onCancel = () => new Future<Null>.value(null);
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(onCancel: onCancel);

      await expectLater(subject.onCancel, onCancel);
    });

    test('sets onCancel callback', () async {
      final ControllerCallback testOnCancel = () {};
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(subject.onCancel, isNull);

      subject.onCancel = testOnCancel;

      await expectLater(subject.onCancel, testOnCancel);
    });

    test('reports if a listener is present', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(subject.hasListener, isFalse);

      subject.stream.listen((_) {});

      await expectLater(subject.hasListener, isTrue);
    });

    test('onPause unsupported', () {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      expect(subject.isPaused, isFalse);
      expect(() => subject.onPause, throwsUnsupportedError);
      expect(() => subject.onPause = () {}, throwsUnsupportedError);
    });

    test('onResume unsupported', () {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      expect(() => subject.onResume, throwsUnsupportedError);
      expect(() => subject.onResume = () {}, throwsUnsupportedError);
    });

    test('returns controller sink', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(subject.sink, new TypeMatcher<EventSink<int>>());
    });

    test('correctly closes done Future', () async {
      final StreamController<int> subject = new BehaviorSubject<int>();

      scheduleMicrotask(() => subject.close());

      await expectLater(subject.done, completes);
    });

    test('can be listened to multiple times', () async {
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(seedValue: 1);
      final Stream<int> stream = subject.stream;

      await expectLater(stream, emits(1));
      await expectLater(stream, emits(1));
    });

    test('always returns the same stream', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expectLater(subject.stream, equals(subject.stream));
    });

    test('adding to sink has same behavior as adding to Subject itself',
        () async {
      // ignore: close_sinks
      final BehaviorSubject<int> subject = new BehaviorSubject<int>();

      subject.sink.add(1);

      expect(subject.value, 1);

      subject.sink.add(2);
      subject.sink.add(3);

      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
    });
  });
}
