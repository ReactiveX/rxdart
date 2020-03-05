import 'dart:async';

/// Helper method which will either return a broadcast, or single subscription
/// [Stream] if the fromStream is broadcast or not.
StreamController<T> createController<T>(Stream forStream,
    {void Function() onListen,
    void Function() onPause,
    void Function() onResume,
    void Function() onCancel}) {
  if (forStream.isBroadcast) {
    return StreamController<T>.broadcast(
        sync: true, onListen: onListen, onCancel: onCancel);
  }

  return StreamController<T>(
      sync: true,
      onListen: onListen,
      onCancel: onCancel,
      onResume: onResume,
      onPause: onPause);
}
