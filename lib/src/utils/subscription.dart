import 'dart:async';

import 'package:rxdart/src/utils/future.dart';

/// Extensions for [Iterable] of [StreamSubscription]s.
extension StreamSubscriptionsIterableExtensions
    on Iterable<StreamSubscription<void>> {
  /// Pause all subscriptions.
  void pauseAll([Future<void>? resumeSignal]) {
    for (final s in this) {
      s.pause(resumeSignal);
    }
  }

  /// Resume all subscriptions.
  void resumeAll() {
    for (final s in this) {
      s.resume();
    }
  }
}

/// Extensions for [Iterable] of [StreamSubscription]s.
extension StreamSubscriptionsIterableExtension
    on Iterable<StreamSubscription<void>> {
  /// Cancel all subscriptions.
  Future<void>? cancelAll() =>
      waitFuturesList([for (final s in this) s.cancel()]);
}
