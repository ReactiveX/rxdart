import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/observable/stream.dart';

class DeferObservable<T> extends StreamObservable<T> with ControllerMixin<T> {
  final Create<T> create;

  DeferObservable(this.create);

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return observable(create()).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

typedef Stream<T> Create<T>();
