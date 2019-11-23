import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

typedef AsyncVoidCallBack = Future<Null> Function();

void main() {
  group('BehaviorSubject', () {
    test('emits the most recently emitted item to every subscriber', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(3);

      seeded.add(1);
      seeded.add(2);
      seeded.add(3);

      await expectLater(unseeded.stream, emits(3));
      await expectLater(unseeded.stream, emits(3));
      await expectLater(unseeded.stream, emits(3));

      await expectLater(seeded.stream, emits(3));
      await expectLater(seeded.stream, emits(3));
      await expectLater(seeded.stream, emits(3));
    });

    test('emits the most recently emitted null item to every subscriber',
        () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(null);

      seeded.add(1);
      seeded.add(2);
      seeded.add(null);

      await expectLater(unseeded.stream, emits(isNull));
      await expectLater(unseeded.stream, emits(isNull));
      await expectLater(unseeded.stream, emits(isNull));

      await expectLater(seeded.stream, emits(isNull));
      await expectLater(seeded.stream, emits(isNull));
      await expectLater(seeded.stream, emits(isNull));
    });

    test(
        'emits the most recently emitted item to every subscriber that subscribe to the subject directly',
        () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(3);

      seeded.add(1);
      seeded.add(2);
      seeded.add(3);

      await expectLater(unseeded, emits(3));
      await expectLater(unseeded, emits(3));
      await expectLater(unseeded, emits(3));

      await expectLater(seeded, emits(3));
      await expectLater(seeded, emits(3));
      await expectLater(seeded, emits(3));
    });

    test('emits errors to every subscriber', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(3);
      unseeded.addError(Exception('oh noes!'));

      seeded.add(1);
      seeded.add(2);
      seeded.add(3);
      seeded.addError(Exception('oh noes!'));

      await expectLater(unseeded.stream, emitsError(isException));
      await expectLater(unseeded.stream, emitsError(isException));
      await expectLater(unseeded.stream, emitsError(isException));

      await expectLater(seeded.stream, emitsError(isException));
      await expectLater(seeded.stream, emitsError(isException));
      await expectLater(seeded.stream, emitsError(isException));
    });

    test('emits event after error to every subscriber', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.addError(Exception('oh noes!'));
      unseeded.add(3);

      seeded.add(1);
      seeded.add(2);
      seeded.addError(Exception('oh noes!'));
      seeded.add(3);

      await expectLater(unseeded.stream, emits(3));
      await expectLater(unseeded.stream, emits(3));
      await expectLater(unseeded.stream, emits(3));

      await expectLater(seeded.stream, emits(3));
      await expectLater(seeded.stream, emits(3));
      await expectLater(seeded.stream, emits(3));
    });

    test('emits errors to every subscriber, ensures value is null', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(3);
      unseeded.addError(Exception('oh noes!'));

      seeded.add(1);
      seeded.add(2);
      seeded.add(3);
      seeded.addError(Exception('oh noes!'));

      await expectLater(unseeded.value, isNull);
      await expectLater(unseeded.value, isNull);
      await expectLater(unseeded.value, isNull);

      await expectLater(seeded.value, isNull);
      await expectLater(seeded.value, isNull);
      await expectLater(seeded.value, isNull);
    });

    test('can synchronously get the latest value', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(3);

      seeded.add(1);
      seeded.add(2);
      seeded.add(3);

      await expectLater(unseeded.value, 3);

      await expectLater(seeded.value, 3);
    });

    test('can synchronously get the latest null value', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      unseeded.add(1);
      unseeded.add(2);
      unseeded.add(null);

      seeded.add(1);
      seeded.add(2);
      seeded.add(null);

      await expectLater(unseeded.value, isNull);

      await expectLater(seeded.value, isNull);
    });

    test('emits the seed item if no new items have been emitted', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>.seeded(1);

      await expectLater(subject.stream, emits(1));
      await expectLater(subject.stream, emits(1));
      await expectLater(subject.stream, emits(1));
    });

    test('emits the null seed item if no new items have been emitted',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>.seeded(null);

      await expectLater(subject.stream, emits(isNull));
      await expectLater(subject.stream, emits(isNull));
      await expectLater(subject.stream, emits(isNull));
    });

    test('can synchronously get the initial value', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>.seeded(1);

      expect(subject.value, 1);
    });

    test('can synchronously get the initial null value', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>.seeded(null);

      expect(subject.value, null);
    });

    test('initial value is null when no value has been emitted', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      expect(subject.value, isNull);
    });

    test('emits done event to listeners when the subject is closed', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      await expectLater(unseeded.isClosed, isFalse);
      await expectLater(seeded.isClosed, isFalse);

      unseeded.add(1);
      scheduleMicrotask(() => unseeded.close());

      seeded.add(1);
      scheduleMicrotask(() => seeded.close());

      await expectLater(unseeded.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(unseeded.isClosed, isTrue);

      await expectLater(seeded.stream, emitsInOrder(<dynamic>[1, emitsDone]));
      await expectLater(seeded.isClosed, isTrue);
    });

    test('emits error events to subscribers', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      scheduleMicrotask(() => unseeded.addError(Exception()));
      scheduleMicrotask(() => seeded.addError(Exception()));

      await expectLater(unseeded.stream, emitsError(isException));
      await expectLater(seeded.stream, emitsError(isException));
    });

    test('replays the previously emitted items from addStream', () async {
      // ignore: close_sinks
      final unseeded = BehaviorSubject<int>(),
          // ignore: close_sinks
          seeded = BehaviorSubject<int>.seeded(0);

      await unseeded.addStream(Stream.fromIterable(const [1, 2, 3]));
      await seeded.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(unseeded.stream, emits(3));
      await expectLater(unseeded.stream, emits(3));
      await expectLater(unseeded.stream, emits(3));

      await expectLater(seeded.stream, emits(3));
      await expectLater(seeded.stream, emits(3));
      await expectLater(seeded.stream, emits(3));
    });

    test('allows items to be added once addStream is complete', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      await subject.addStream(Stream.fromIterable(const [1, 2]));
      subject.add(3);

      await expectLater(subject.stream, emits(3));
    });

    test('allows items to be added once addStream is completes with an error',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<void>();

      await expectLater(
          subject.addStream(Stream<void>.error(Exception()),
              cancelOnError: true),
          throwsException);

      subject.add(1);

      await expectLater(subject.stream, emits(1));
    });

    test('does not allow events to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.add(1), throwsStateError);
    });

    test('does not allow errors to be added when addStream is active',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addError(Error()), throwsStateError);
    });

    test('does not allow subject to be closed when addStream is active',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.close(), throwsStateError);
    });

    test(
        'does not allow addStream to add items when previous addStream is active',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      // Purposely don't wait for the future to complete, then try to add items
      // ignore: unawaited_futures
      subject.addStream(Stream.fromIterable(const [1, 2, 3]));

      await expectLater(() => subject.addStream(Stream.fromIterable(const [1])),
          throwsStateError);
    });

    test('returns onListen callback set in constructor', () async {
      final testOnListen = () {};
      // ignore: close_sinks
      final subject = BehaviorSubject<void>(onListen: testOnListen);

      await expectLater(subject.onListen, testOnListen);
    });

    test('sets onListen callback', () async {
      final testOnListen = () {};
      // ignore: close_sinks
      final subject = BehaviorSubject<void>();

      await expectLater(subject.onListen, isNull);

      subject.onListen = testOnListen;

      await expectLater(subject.onListen, testOnListen);
    });

    test('returns onCancel callback set in constructor', () async {
      final onCancel = () => Future<void>.value(null);
      // ignore: close_sinks
      final subject = BehaviorSubject<void>(onCancel: onCancel);

      await expectLater(subject.onCancel, onCancel);
    });

    test('sets onCancel callback', () async {
      final testOnCancel = () {};
      // ignore: close_sinks
      final subject = BehaviorSubject<void>();

      await expectLater(subject.onCancel, isNull);

      subject.onCancel = testOnCancel;

      await expectLater(subject.onCancel, testOnCancel);
    });

    test('reports if a listener is present', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      await expectLater(subject.hasListener, isFalse);

      subject.stream.listen(null);

      await expectLater(subject.hasListener, isTrue);
    });

    test('onPause unsupported', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      expect(subject.isPaused, isFalse);
      expect(() => subject.onPause, throwsUnsupportedError);
      expect(() => subject.onPause = () {}, throwsUnsupportedError);
    });

    test('onResume unsupported', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      expect(() => subject.onResume, throwsUnsupportedError);
      expect(() => subject.onResume = () {}, throwsUnsupportedError);
    });

    test('returns controller sink', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      await expectLater(subject.sink, TypeMatcher<EventSink<int>>());
    });

    test('correctly closes done Future', () async {
      final subject = BehaviorSubject<void>();

      scheduleMicrotask(() => subject.close());

      await expectLater(subject.done, completes);
    });

    test('can be listened to multiple times', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject.seeded(1);
      final stream = subject.stream;

      await expectLater(stream, emits(1));
      await expectLater(stream, emits(1));
    });

    test('always returns the same stream', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      await expectLater(subject.stream, equals(subject.stream));
    });

    test('adding to sink has same behavior as adding to Subject itself',
        () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      subject.sink.add(1);

      expect(subject.value, 1);

      subject.sink.add(2);
      subject.sink.add(3);

      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
      await expectLater(subject.stream, emits(3));
    });

    test('is always treated as a broadcast Stream', () async {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();
      final stream = subject.asyncMap((event) => Future.value(event));

      expect(subject.isBroadcast, isTrue);
      expect(stream.isBroadcast, isTrue);
    });

    test('hasValue returns false for an empty subject', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      expect(subject.hasValue, isFalse);
    });

    test('hasValue returns true for a seeded subject with non-null seed', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>.seeded(1);

      expect(subject.hasValue, isTrue);
    });

    test('hasValue returns true for a seeded subject with null seed', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>.seeded(null);

      expect(subject.hasValue, isTrue);
    });

    test('hasValue returns true for an unseeded subject after an emission', () {
      // ignore: close_sinks
      final subject = BehaviorSubject<int>();

      subject.add(1);

      expect(subject.hasValue, isTrue);
    });

    test(
        'issue/350: emits duplicate values when listening multiple times and starting with an Error',
        () async {
      final subject = BehaviorSubject<dynamic>();

      subject.addError('error');

      await subject.close();

      await expectLater(subject,
          emitsInOrder(<StreamMatcher>[emitsError('error'), emitsDone]));
      await expectLater(subject,
          emitsInOrder(<StreamMatcher>[emitsError('error'), emitsDone]));
      await expectLater(subject,
          emitsInOrder(<StreamMatcher>[emitsError('error'), emitsDone]));
    });
  });
}
