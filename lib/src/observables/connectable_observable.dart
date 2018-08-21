import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class ConnectableObservable<T> {
  Observable<T> autoConnect({int numberOfSubscribers});
  StreamSubscription<T> connect();
  Observable<T> refCount();
}
