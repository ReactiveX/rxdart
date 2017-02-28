import 'dart:async';

import 'package:rxdart/src/streams/utils.dart';

class DeferStream<T> extends Stream<T> {
  final StreamFactory<T> streamFactory;
  bool _isUsed = false;

  DeferStream(this.streamFactory);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (_isUsed) throw new StateError("Stream has already been listened to.");
    _isUsed = true;

    return streamFactory().listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
