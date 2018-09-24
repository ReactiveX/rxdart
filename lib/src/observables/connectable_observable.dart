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
/// a broadcast Stream.
class PublishConnectableObservable<T> extends ConnectableObservable<T> {
  final Stream<T> _source;
  final PublishSubject<T> _subject;

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

  factory ValueConnectableObservable(Stream<T> source, {T seedValue}) =>
      ValueConnectableObservable<T>._(
          source, BehaviorSubject<T>(seedValue: seedValue));

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
}

/// A [ConnectableObservable] that converts a single-subscription Stream into
/// a broadcast Stream that replays emitted items to any new listener, and
/// provides synchronous access to the list of emitted values.
class ReplayConnectableObservable<T> extends ConnectableObservable<T>
    implements ReplayObservable<T> {
  final Stream<T> _source;
  final ReplaySubject<T> _subject;

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
