import 'dart:async';
import 'dart:collection';

/// Extensions for [List] of [StreamSubscription]s.
extension StreamSubscriptionsListExtensions on List<StreamSubscription<void>> {
  /// Pause all subscriptions.
  void pauseAll([Future<void>? resumeSignal]) =>
      forEach((s) => s.pause(resumeSignal));

  /// Resume all subscriptions.
  void resumeAll() => forEach((s) => s.resume());

  /// Cancel all subscriptions.
  Future<void> cancelAll() {
    if (isEmpty) {
      return Future.value();
    }
    if (length == 1) {
      return this[0].cancel();
    }
    return Future.wait(map((s) => s.cancel()));
  }
}

/// Extensions for [Queue] of [StreamSubscription]s.
extension StreamSubscriptionsQueueExtensions
    on Queue<StreamSubscription<void>> {
  /// Pause all subscriptions.
  void pauseAll([Future<void>? resumeSignal]) =>
      forEach((s) => s.pause(resumeSignal));

  /// Resume all subscriptions.
  void resumeAll() => forEach((s) => s.resume());

  /// Cancel all subscriptions.
  Future<void> cancelAll() {
    if (isEmpty) {
      return Future.value();
    }
    if (length == 1) {
      return first.cancel();
    }
    return Future.wait(map((s) => s.cancel()));
  }
}
