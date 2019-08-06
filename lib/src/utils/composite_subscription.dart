import 'dart:async';

/// Acts as a container for multiple subscriptions that can be canceled at once
/// e.g. view subcriptions in Flutter that need to be canceled on view disposal
///
/// Can be cleared or disposed. When disposed, cannot be used again.
/// ### Example
/// // init your subscriptions
/// composite.add(observable1.listen(listener1))
/// ..add(observable2.listen(listener1))
/// ..add(observable3.listen(listener1));
///
/// // clear them all at once
/// composite.clear();
class CompositeSubscription {
  bool _isDisposed = false;

  final List<StreamSubscription<dynamic>> _subscriptionsList =
      List<StreamSubscription<dynamic>>();

  /// Checks if this composite is disposed. If it is, the composite can't be used again
  /// and will throw an error if you try to add more subscriptions to it.
  bool get isDisposed => _isDisposed;

  /// Adds new subscription to this composite.
  ///
  /// Throws an exception if this composite was disposed
  StreamSubscription<T> add<T>(StreamSubscription<T> subscription) {
    if (isDisposed) {
      throw ("This composite was disposed, try to use new instance instead");
    }
    _subscriptionsList.add(subscription);
    return subscription;
  }

  /// Cancels subscripiton and removes it from this composite.
  void remove(StreamSubscription<dynamic> subscription) {
    subscription.cancel();
    _subscriptionsList.remove(subscription);
  }

  /// Cancels all subscriptions added to this composite. Clears subscriptions collection.
  ///
  /// This composite can be reused after calling this method.
  void clear() {
    _subscriptionsList.forEach(
        (StreamSubscription<dynamic> subscription) => subscription.cancel());
    _subscriptionsList.clear();
  }

  /// Cancels all subscriptions added to this composite. Disposes this.
  ///
  /// This composite can't be reused after calling this method.
  void dispose() {
    clear();
    _isDisposed = true;
  }
}
