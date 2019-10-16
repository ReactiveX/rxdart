import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observables/replay_observable.dart';

/// A ConnectableObservable resembles an ordinary Observable, except that it
/// can be listened to multiple times and does not begin emitting items when
/// it is listened to, but only when its [connect] method is called.
///
/// This class can be used to broadcast a single-subscription Stream, and
/// can be used to wait for all intended Observers to [listen] to the
/// Observable before it begins emitting items.
abstract class ConnectableObservable<T> extends Observable<T> {
  /// Constructs an [Observable] which only begins emitting events when
  /// the [connect] method is called.
  ConnectableObservable(Stream<T> stream) : super(stream);

  /// Returns an Observable that automatically connects (at most once) to this
  /// ConnectableObservable when the first Observer subscribes.
  ///
  /// To disconnect from the source Stream, provide a [connection] callback and
  /// cancel the `subscription` at the appropriate time.
  Observable<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  });

  /// Instructs the [ConnectableObservable] to begin emitting items from the
  /// source Stream. To disconnect from the source stream, cancel the
  /// subscription.
  StreamSubscription<T> connect();

  /// Returns an Observable that stays connected to this ConnectableObservable
  /// as long as there is at least one subscription to this
  /// ConnectableObservable.
  Observable<T> refCount();
}

/// A [ConnectableObservable] that converts a single-subscription Stream into
/// a broadcast [Stream].
class PublishConnectableObservable<T> extends ConnectableObservable<T> {
  final Stream<T> _source;
  final PublishSubject<T> _subject;

  /// Constructs an [Observable] which only begins emitting events when
  /// the [connect] method is called, this [Observable] acts like a
  /// [PublishSubject].
  factory PublishConnectableObservable(Stream<T> source) {
    return PublishConnectableObservable<T>._(source, PublishSubject<T>());
  }

  PublishConnectableObservable._(this._source, this._subject) : super(_subject);

  @override
  Observable<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_subject.add, onError: _subject.addError),
      _subject,
    );
  }

  @override
  Observable<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_subject.add, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }
}

/// A [ConnectableObservable] that converts a single-subscription Stream into
/// a broadcast Stream that replays the latest value to any new listener, and
/// provides synchronous access to the latest emitted value.
class ValueConnectableObservable<T> extends ConnectableObservable<T>
    implements ValueObservable<T> {
  final Stream<T> _source;
  final BehaviorSubject<T> _subject;

  ValueConnectableObservable._(this._source, this._subject) : super(_subject);

  /// Constructs an [Observable] which only begins emitting events when
  /// the [connect] method is called, this [Observable] acts like a
  /// [BehaviorSubject].
  factory ValueConnectableObservable(Stream<T> source) =>
      ValueConnectableObservable<T>._(
        source,
        BehaviorSubject<T>(),
      );

  /// Constructs an [Observable] which only begins emitting events when
  /// the [connect] method is called, this [Observable] acts like a
  /// [BehaviorSubject.seeded].
  factory ValueConnectableObservable.seeded(
    Stream<T> source,
    T seedValue,
  ) =>
      ValueConnectableObservable<T>._(
        source,
        BehaviorSubject<T>.seeded(seedValue),
      );

  @override
  ValueObservable<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_subject.add, onError: _subject.addError),
      _subject,
    );
  }

  @override
  ValueObservable<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_subject.add, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }

  @override
  T get value => _subject.value;

  @override
  bool get hasValue => _subject.hasValue;
}

/// A [ConnectableObservable] that converts a single-subscription Stream into
/// a broadcast Stream that replays emitted items to any new listener, and
/// provides synchronous access to the list of emitted values.
class ReplayConnectableObservable<T> extends ConnectableObservable<T>
    implements ReplayObservable<T> {
  final Stream<T> _source;
  final ReplaySubject<T> _subject;

  /// Constructs an [Observable] which only begins emitting events when
  /// the [connect] method is called, this [Observable] acts like a
  /// [ReplaySubject].
  factory ReplayConnectableObservable(Stream<T> stream, {int maxSize}) {
    return ReplayConnectableObservable<T>._(
      stream,
      ReplaySubject<T>(maxSize: maxSize),
    );
  }

  ReplayConnectableObservable._(this._source, this._subject) : super(_subject);

  @override
  ReplayObservable<T> autoConnect({
    void Function(StreamSubscription<T> subscription) connection,
  }) {
    _subject.onListen = () {
      if (connection != null) {
        connection(connect());
      } else {
        connect();
      }
    };

    return _subject;
  }

  @override
  StreamSubscription<T> connect() {
    return ConnectableObservableStreamSubscription<T>(
      _source.listen(_subject.add, onError: _subject.addError),
      _subject,
    );
  }

  @override
  ReplayObservable<T> refCount() {
    ConnectableObservableStreamSubscription<T> subscription;

    _subject.onListen = () {
      subscription = ConnectableObservableStreamSubscription<T>(
        _source.listen(_subject.add, onError: _subject.addError),
        _subject,
      );
    };

    _subject.onCancel = () {
      subscription.cancel();
    };

    return _subject;
  }

  @override
  List<T> get values => _subject.values;
}

/// A special [StreamSubscription] that not only cancels the connection to
/// the source [Stream], but also closes down a subject that drives the Stream.
class ConnectableObservableStreamSubscription<T> extends StreamSubscription<T> {
  final StreamSubscription<T> _source;
  final Subject<T> _subject;

  /// Constructs a special [StreamSubscription], which will close the provided subject
  /// when [cancel] is called.
  ConnectableObservableStreamSubscription(this._source, this._subject);

  @override
  Future<dynamic> cancel() {
    _subject.close();
    return _source.cancel();
  }

  @override
  Future<E> asFuture<E>([E futureValue]) => _source.asFuture(futureValue);

  @override
  bool get isPaused => _source.isPaused;

  @override
  void onData(void Function(T data) handleData) => _source.onData(handleData);

  @override
  void onDone(void Function() handleDone) => _source.onDone(handleDone);

  @override
  void onError(Function handleError) => _source.onError(handleError);

  @override
  void pause([Future<dynamic> resumeSignal]) => _source.pause(resumeSignal);

  @override
  void resume() => _source.resume();
}

extension ConnectableObservableExtensions<T> on Stream<T> {
  /// Convert the current Observable into a [ConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publish();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // Subject
  /// subscription.cancel();
  /// ```
  ConnectableObservable<T> publish() => PublishConnectableObservable<T>(this);

  /// Convert the current Observable into a [ValueConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValue();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
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
  ValueConnectableObservable<T> publishValue() =>
      ValueConnectableObservable<T>(this);

  /// Convert the current Observable into a [ValueConnectableObservable]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Observable
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValueSeeded(0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
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
  ValueConnectableObservable<T> publishValueSeeded(T seedValue) =>
      ValueConnectableObservable<T>.seeded(this, seedValue);

  /// Convert the current Observable into a [ReplayConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays a given number of items to any new
  /// listener. It also provides access to the emitted values synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishReplay();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
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
  ReplayConnectableObservable<T> publishReplay({int maxSize}) =>
      ReplayConnectableObservable<T>(this, maxSize: maxSize);

  /// Convert the current Observable into a new Observable that can be listened
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
  /// final observable = Observable.fromIterable([1, 2, 3]).share();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // PublishSubject
  /// subscription.cancel();
  /// ```
  Stream<T> share() => publish().refCount();

  /// Convert the current Observable into a new [ValueObservable] that can
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
  /// final observable = Observable.fromIterable([1, 2, 3]).shareValue();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValue() => publishValue().refCount();

  /// Convert the current Observable into a new [ValueObservable] that can
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
  /// final observable = Observable.fromIterable([1, 2, 3]).shareValueSeeded(0);
  ///
  /// // Start listening to the source Observable. Will start printing 0, 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValueSeeded(T seedValue) =>
      publishValueSeeded(seedValue).refCount();

  /// Convert the current Observable into a new [ReplayObservable] that can
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
  /// final observable = Observable.fromIterable([1, 2, 3]).shareReplay();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the emitted values up to a given maxSize
  /// // Prints [1, 2, 3]
  /// print(observable.values);
  ///
  /// // Subscribe again later. This will print 1, 2, 3 because it receives the
  /// // last emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ReplayObservable<T> shareReplay({int maxSize}) =>
      publishReplay(maxSize: maxSize).refCount();
}
