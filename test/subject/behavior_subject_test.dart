import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  group('BehaviorSubject', () {
    test('emits the most recently emitted item to every subscriber', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      subject.add(1);
      subject.add(2);
      subject.add(3);

      await expect(subject.stream, emits(3));
      await expect(subject.stream, emits(3));
      await expect(subject.stream, emits(3));
    });

    test('emits the seed item if no new items have been emitted', () async {
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(seedValue: 1);

      await expect(subject.stream, emits(1));
      await expect(subject.stream, emits(1));
      await expect(subject.stream, emits(1));
    });

    test('emits done event to listeners when the subject is closed', () async {
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expect(subject.isClosed, isFalse);

      subject.add(1);
      scheduleMicrotask(() => subject.close());

      await expect(subject.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expect(subject.isClosed, isTrue);
    });

    test('emits error events to subscribers', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      scheduleMicrotask(() => subject.addError(new Exception()));

      await expect(subject.stream, emitsError(isException));
    });

    test('replays the previously emitted items from addStream', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expect(subject.stream, emits(3));
      await expect(subject.stream, emits(3));
      await expect(subject.stream, emits(3));
    });

    test('allows items to be added once addStream is complete', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await subject.addStream(new Stream<int>.fromIterable(<int>[1, 2]));
      subject.add(3);

      await expect(subject.stream, emits(3));
    });

    test('allows items to be added once addStream is completes with an error',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expect(
          subject.addStream(new ErrorStream<int>(new Exception()),
              cancelOnError: true),
          throwsException);

      subject.add(1);

      await expect(subject.stream, emits(1));
    });

    test('does not allow events to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expect(() => subject.add(1), throwsStateError);
    });

    test('does not allow errors to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expect(() => subject.addError(new Error()), throwsStateError);
    });

    test('does not allow subject to be closed when addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expect(() => subject.close(), throwsStateError);
    });

    test(
        'does not allow addStream to add items when previous addStream is active',
        () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(new Stream<int>.fromIterable(<int>[1, 2, 3]));

      await expect(
          () => subject.addStream(new Stream<int>.fromIterable(<int>[1])),
          throwsStateError);
    });

    test('returns onListen callback set in constructor', () async {
      final ControllerCallback testOnListen = () {};
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(onListen: testOnListen);

      await expect(subject.onListen, testOnListen);
    });

    test('sets onListen callback', () async {
      final ControllerCallback testOnListen = () {};
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expect(subject.onListen, isNull);

      subject.onListen = testOnListen;

      await expect(subject.onListen, testOnListen);
    });

    test('returns onCancel callback set in constructor', () async {
      final ControllerCallback testOnCancel = () {};
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(onCancel: testOnCancel);

      await expect(subject.onCancel, testOnCancel);
    });

    test('sets onCancel callback', () async {
      final ControllerCallback testOnCancel = () {};
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expect(subject.onCancel, isNull);

      subject.onCancel = testOnCancel;

      await expect(subject.onCancel, testOnCancel);
    });

    test('reports if a listener is present', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expect(subject.hasListener, isFalse);

      subject.stream.listen((_) {});

      await expect(subject.hasListener, isTrue);
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

      await expect(subject.sink, new isInstanceOf<EventSink<int>>());
    });

    test('correctly closes done Future', () async {
      final StreamController<int> subject = new BehaviorSubject<int>();

      scheduleMicrotask(() => subject.close());

      await expect(subject.done, completes);
    });

    test('can be listened to multiple times', () async {
      // ignore: close_sinks
      final StreamController<int> subject =
          new BehaviorSubject<int>(seedValue: 1);
      final Stream<int> stream = subject.stream;

      await expect(stream, emits(1));
      await expect(stream, emits(1));
    });

    test('always returns the same stream', () async {
      // ignore: close_sinks
      final StreamController<int> subject = new BehaviorSubject<int>();

      await expect(subject.stream, equals(subject.stream));
    });
  });
}
