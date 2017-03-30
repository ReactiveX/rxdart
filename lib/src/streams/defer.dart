import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

/// The defer factory waits until an observer subscribes to it, and then it
/// creates an Observable with the given factory function.
///
/// In some circumstances, waiting until the last minute (that is, until
/// subscription time) to generate the Observable can ensure that this
/// Observable contains the freshest data.
///
/// By default, DeferStream is single-subscription as it cannot guarantee the
/// source streams will be broadcast streams. If, however, you are certain the
/// source streams are broadcast stream, you can allow the DeferStream to be
/// subscribed to multiple times.
///
/// ### Example
///
///     new DeferStream(() => new Observable.just(1)).listen(print); //prints 1
class DeferStream<T> extends Stream<T> {
  final StreamFactory<T> _streamFactory;
  final bool _isBroadcastStream;
  bool _isUsed = false;

  DeferStream(this._streamFactory, {bool broadcast: false})
      : _isBroadcastStream = broadcast;

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (_isUsed && !_isBroadcastStream)
      throw new StateError("Stream has already been listened to.");
    _isUsed = true;

    return _streamFactory().listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
