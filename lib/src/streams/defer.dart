import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

/// The defer factory waits until an observer subscribes to it, and then it
/// creates an Observable with the given factory function.
///
/// In some circumstances, waiting until the last minute (that is, until
/// subscription time) to generate the Observable can ensure that this
/// Observable contains the freshest data.
///
/// By default, DeferStreams are single-subscription. However, it's possible
/// to make them reusable.
///
/// ### Example
///
///     new DeferStream(() => new Observable.just(1)).listen(print); //prints 1
class DeferStream<T> extends Stream<T> {
  final StreamFactory<T> _streamFactory;
  final bool _isReusable;
  bool _isUsed = false;

  @override
  bool get isBroadcast => _isReusable;

  DeferStream(this._streamFactory, {bool reusable = false})
      : _isReusable = reusable;

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (_isUsed && !_isReusable)
      throw StateError("Stream has already been listened to.");
    _isUsed = true;

    return _streamFactory().listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
