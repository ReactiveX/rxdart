import 'dart:async';

import 'package:rxdart/src/streams/replay_stream.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

/// A ConnectableStream resembles an ordinary Stream, except that it
/// can be listened to multiple times and does not begin emitting items when
/// it is listened to, but only when its [connect] method is called.
///
/// This class can be used to broadcast a single-subscription Stream, and
/// can be used to wait for all intended Observers to [listen] to the
/// Stream before it begins emitting items.
abstract class ConnectableStream<T> extends StreamView<T> {
  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called.
  ConnectableStream(Stream<T> stream) : super(stream);

  /// Returns a [Stream] that automatically connects (at most once) to this
  /// ConnectableStream when the first Observer subscribes.
  ///
  /// To disconnect from the source Stream, provide a [connection] callback and
  /// cancel the `subscription` at the appropriate time.
  Stream<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  });

  /// Instructs the [ConnectableStream] to begin emitting items from the
  /// source Stream. To disconnect from the source stream, cancel the
  /// subscription.
  StreamSubscription<T> connect();

  /// Returns a [Stream] that stays connected to this ConnectableStream
  /// as long as there is at least one subscription to this
  /// ConnectableStream.
  Stream<T> refCount();
}

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast [Stream].
class PublishConnectableStream<T> extends ConnectableStream<T> {
  final Stream<T> _source;
  final PublishSubject<T> _subject;

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [PublishSubject].
  factory PublishConnectableStream(Stream<T> source, {bool sync = false}) {
    return PublishConnectableStream<T>._(source, PublishSubject<T>(sync: sync));
  }

  PublishConnectableStream._(this._source, this._subject) : super(_subject);

  late final _connection = ConnectableStreamSubscription<T>(
    _source.listen(
      _subject.add,
      onError: _subject.addError,
      onDone: _subject.close,
    ),
    _subject,
  );

  @override
  Stream<T> autoConnect({
    void Function(StreamSubscription<T> subscription)? connection,
  }) {
    _subject.onListen = () {
      final subscription = _connection;
      connection?.call(subscription);
    };
    _subject.onCancel = null;

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    _subject.onListen = _subject.onCancel = null;
    return _connection;
  }

  @override
  Stream<T> refCount() {
    ConnectableStreamSubscription<T>? subscription;

    _subject.onListen = () => subscription = _connection;
    _subject.onCancel = () => subscription?.cancel();

    return _subject;
  }
}

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast Stream that replays the latest value to any new listener, and
/// provides synchronous access to the latest emitted value.
class ValueConnectableStream<T> extends ConnectableStream<T>
    implements ValueStream<T> {
  final Stream<T> _source;
  final BehaviorSubject<T> _subject;

  ValueConnectableStream._(this._source, this._subject) : super(_subject);

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [BehaviorSubject].
  factory ValueConnectableStream(Stream<T> source, {bool sync = false}) =>
      ValueConnectableStream<T>._(
        source,
        BehaviorSubject<T>(sync: sync),
      );

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [BehaviorSubject.seeded].
  factory ValueConnectableStream.seeded(Stream<T> source, T seedValue,
          {bool sync = false}) =>
      ValueConnectableStream<T>._(
        source,
        BehaviorSubject<T>.seeded(seedValue, sync: sync),
      );

  late final _connection = ConnectableStreamSubscription<T>(
    _source.listen(
      _subject.add,
      onError: _subject.addError,
      onDone: _subject.close,
    ),
    _subject,
  );

  @override
  ValueStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription)? connection,
  }) {
    _subject.onListen = () {
      final subscription = _connection;
      connection?.call(subscription);
    };
    _subject.onCancel = null;

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    _subject.onListen = _subject.onCancel = null;
    return _connection;
  }

  @override
  ValueStream<T> refCount() {
    StreamSubscription<T>? subscription;

    _subject.onListen = () => subscription = _connection;
    _subject.onCancel = () => subscription?.cancel();

    return _subject;
  }

  @override
  bool get hasValue => _subject.hasValue;

  @override
  T get value => _subject.value;

  @override
  T? get valueOrNull => _subject.valueOrNull;

  @override
  Object get error => _subject.error;

  @override
  Object? get errorOrNull => _subject.errorOrNull;

  @override
  bool get hasError => _subject.hasError;

  @override
  StackTrace? get stackTrace => _subject.stackTrace;
}

/// A [ConnectableStream] that converts a single-subscription Stream into
/// a broadcast Stream that replays emitted items to any new listener, and
/// provides synchronous access to the list of emitted values.
class ReplayConnectableStream<T> extends ConnectableStream<T>
    implements ReplayStream<T> {
  final Stream<T> _source;
  final ReplaySubject<T> _subject;

  /// Constructs a [Stream] which only begins emitting events when
  /// the [connect] method is called, this [Stream] acts like a
  /// [ReplaySubject].
  factory ReplayConnectableStream(Stream<T> stream,
      {int? maxSize, bool sync = false}) {
    return ReplayConnectableStream<T>._(
      stream,
      ReplaySubject<T>(maxSize: maxSize, sync: sync),
    );
  }

  ReplayConnectableStream._(this._source, this._subject) : super(_subject);

  late final _connection = ConnectableStreamSubscription<T>(
    _source.listen(
      _subject.add,
      onError: _subject.addError,
      onDone: _subject.close,
    ),
    _subject,
  );

  @override
  ReplayStream<T> autoConnect({
    void Function(StreamSubscription<T> subscription)? connection,
  }) {
    _subject.onListen = () {
      final subscription = _connection;
      connection?.call(subscription);
    };
    _subject.onCancel = null;

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    _subject.onListen = _subject.onCancel = null;
    return _connection;
  }

  @override
  ReplayStream<T> refCount() {
    ConnectableStreamSubscription<T>? subscription;

    _subject.onListen = () => subscription = _connection;
    _subject.onCancel = () => subscription?.cancel();

    return _subject;
  }

  @override
  List<T> get values => _subject.values;

  @override
  List<Object> get errors => _subject.errors;

  @override
  List<StackTrace?> get stackTraces => _subject.stackTraces;
}

/// A special [StreamSubscription] that not only cancels the connection to
/// the source [Stream], but also closes down a subject that drives the Stream.
class ConnectableStreamSubscription<T> extends StreamSubscription<T> {
  final StreamSubscription<T> _source;
  final Subject<T> _subject;

  /// Constructs a special [StreamSubscription], which will close the provided subject
  /// when [cancel] is called.
  ConnectableStreamSubscription(this._source, this._subject);

  @override
  Future<dynamic> cancel() =>
      _source.cancel().then<void>((_) => _subject.close());

  @override
  Never asFuture<E>([E? futureValue]) => _unsupportedError();

  @override
  bool get isPaused => _source.isPaused;

  @override
  Never onData(void Function(T data)? handleData) => _unsupportedError();

  @override
  Never onDone(void Function()? handleDone) => _unsupportedError();

  @override
  Never onError(Function? handleError) => _unsupportedError();

  @override
  void pause([Future<void>? resumeSignal]) => _source.pause(resumeSignal);

  @override
  void resume() => _source.resume();

  Never _unsupportedError() => throw UnsupportedError(
      'Cannot change handlers of ConnectableStreamSubscription.');
}

/// Extends the Stream class with the ability to transform a single-subscription
/// Stream into a ConnectableStream.
extension ConnectableStreamExtensions<T> on Stream<T> {
  /// Convert the current Stream into a [ConnectableStream] that can be listened
  /// to multiple times. It will not begin emitting items from the original
  /// Stream until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 3]);
  /// final connectable = source.publish();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // Subject
  /// subscription.cancel();
  /// ```
  ConnectableStream<T> publish() =>
      PublishConnectableStream<T>(this, sync: true);

  /// Convert the current Stream into a [ValueConnectableStream]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Stream until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValue();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the last emitted value
  /// connectable.listen(print); // Prints 3
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject
  /// subscription.cancel();
  /// ```
  ValueConnectableStream<T> publishValue() =>
      ValueConnectableStream<T>(this, sync: true);

  /// Convert the current Stream into a [ValueConnectableStream]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Stream
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValueSeeded(0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 0, 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the last emitted value
  /// connectable.listen(print); // Prints 3
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject
  /// subscription.cancel();
  /// ```
  ValueConnectableStream<T> publishValueSeeded(T seedValue) =>
      ValueConnectableStream<T>.seeded(this, seedValue, sync: true);

  /// Convert the current Stream into a [ReplayConnectableStream]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Stream until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays a given number of items to any new
  /// listener. It also provides access to the emitted values synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Stream.fromIterable([1, 2, 3]);
  /// final connectable = source.publishReplay();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Stream. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the emitted value, up to a specified
  /// // maxSize
  /// connectable.listen(print); // Prints 1, 2, 3
  ///
  /// // Can access a list of the emitted values synchronously. Prints [1, 2, 3]
  /// print(connectable.values);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject
  /// subscription.cancel();
  /// ```
  ReplayConnectableStream<T> publishReplay({int? maxSize}) =>
      ReplayConnectableStream<T>(this, maxSize: maxSize, sync: true);

  /// Convert the current Stream into a new Stream that can be listened
  /// to multiple times. It will automatically begin emitting items when first
  /// listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream
  /// final stream =  Stream.fromIterable([1, 2, 3]).share();
  ///
  /// // Start listening to the source Stream. Will start printing 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // PublishSubject
  /// subscription.cancel();
  /// ```
  Stream<T> share() => publish().refCount();

  /// Convert the current Stream into a new [ValueStream] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// It will replay the latest emitted value to any new listener.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final stream =  Stream.fromIterable([1, 2, 3]).shareValue();
  ///
  /// // Start listening to the source Stream. Will start printing 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(stream.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueStream<T> shareValue() => publishValue().refCount();

  /// Convert the current Stream into a new [ValueStream] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// It will replay the latest emitted value to any new listener.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final stream =  Stream.fromIterable([1, 2, 3]).shareValueSeeded(0);
  ///
  /// // Start listening to the source Stream. Will start printing 0, 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(stream.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueStream<T> shareValueSeeded(T seedValue) =>
      publishValueSeeded(seedValue).refCount();

  /// Convert the current Stream into a new [ReplayStream] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for gaining access to the l
  ///
  /// It will replay the emitted values to any new listener, up to a given
  /// [maxSize].
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final stream =  Stream.fromIterable([1, 2, 3]).shareReplay();
  ///
  /// // Start listening to the source Stream. Will start printing 1, 2, 3
  /// final subscription = stream.listen(print);
  ///
  /// // Synchronously print the emitted values up to a given maxSize
  /// // Prints [1, 2, 3]
  /// print(stream.values);
  ///
  /// // Subscribe again later. This will print 1, 2, 3 because it receives the
  /// // last emitted value.
  /// final subscription2 = stream.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ReplayStream<T> shareReplay({int? maxSize}) =>
      publishReplay(maxSize: maxSize).refCount();
}
