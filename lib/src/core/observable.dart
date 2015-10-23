part of rx.core;

Stream bypass(Stream stream, Observable handler(Observable target)) => handler(new Observable.fromStream(stream)).toStream();

class Observable<T> {
  
  final Rx.Observable _proxy;
  
  Observable._internal(this._proxy);
  
  factory Observable.combineLatest(List<Observable> observables, [Function resultSelector]) {
    final List proxies = observables.map((Observable O) => O._proxy).toList();
    
    if (resultSelector != null) proxies.add(allowInterop(resultSelector));
    
    return new Observable<T>._internal(context['Rx']['Observable'].callMethod('combineLatest', proxies));
  }
  
  factory Observable.from(List elements) => new Observable<T>._internal(Rx.Observable.from(elements));
  
  factory Observable.fromEvent(Element element, String event) => new Observable<T>._internal(Rx.Observable.fromEvent(element, event));
  
  factory Observable.fromFuture(Future future) {
    final Core.Promise promise = new Core.Promise(allowInterop((resolve, reject) {
      future.then((T result) {
        resolve(result);
      }, 
      onError: (error) {
        reject(error);
      });
    }));
    
    return new Observable<T>._internal(Rx.Observable.fromPromise(promise));
  }
  
  factory Observable.fromStream(Stream<T> stream) {
    final Subject S = new Subject();
    
    stream.listen(S.onNext, onError: S.onError, onDone: S.onCompleted);
    
    return new Observable<T>._internal(S._proxy);
  }
  
  factory Observable.merge(List<Observable> observables) => new Observable<T>._internal(context['Rx']['Observable'].callMethod('merge', observables.map((Observable O) => O._proxy).toList()));
  
  factory Observable.mergeWith(Scheduler scheduler, List<Observable> observables) => new Observable<T>._internal(context['Rx']['Observable'].callMethod('merge', observables.map((Observable O) => O._proxy).toList()..insert(0, scheduler._proxy)));
  
  factory Observable.of(T value) => new Observable<T>._internal(Rx.Observable.of(value));
  
  factory Observable.range(int start, int count) => new Observable<T>._internal(Rx.Observable.range(start, count));
  
  factory Observable.repeat(T value, [int repeatCount=-1, Scheduler scheduler]) => new Observable<T>._internal(Rx.Observable.repeat(value, repeatCount, scheduler?._proxy));
  
  factory Observable.timer(Duration interval) => new Observable<T>._internal(Rx.Observable.timer(interval.inMilliseconds));
  
  Observable<List<T>> bufferWithCount(int count, [int skip]) => new Observable<List<T>>._internal(_proxy.bufferWithCount(count, skip));
  
  Observable<T> filter(bool predicate(T value)) => new Observable._internal(_proxy.filter(allowInterop((T value, int index, Rx.Observable target) => predicate(value))));
  
  Observable flatMap(Observable selector(T value)) => new Observable._internal(_proxy.flatMap(allowInterop((T value, int index, Rx.Observable target) => selector(value)._proxy)));
  
  Observable flatMapLatest(Observable selector(T value)) => new Observable._internal(_proxy.flatMapLatest(allowInterop((T value, int index, Rx.Observable target) => selector(value)._proxy)));
  
  Observable map(dynamic selector(T value)) => new Observable._internal(_proxy.map(allowInterop((T value, int index, Rx.Observable target) => selector(value))));
  
  Observable<T> debounce(Duration duration, [Scheduler scheduler]) => new Observable<T>._internal(_proxy.debounce(duration.inMilliseconds, scheduler?._proxy));
  
  Observable<T> delay(Duration duration) => new Observable<T>._internal(_proxy.delay(duration.inMilliseconds));
  
  Observable<T> delayUntil(DateTime dateTime) => new Observable<T>._internal(_proxy.delay(dateTime));
  
  Observable<T> delayWithSubscriptionDelay(Observable<int> subscriptionDelay, [Observable<int> delayDurationSelector(int interval)]) => new Observable<T>._internal(_proxy.delay(subscriptionDelay._proxy, allowInterop((int interval) => delayDurationSelector(interval)._proxy)));
  
  Observable<T> delayWithDurationSelector(Observable<int> delayDurationSelector(int interval)) => new Observable<T>._internal(_proxy.delay(allowInterop((int interval) => delayDurationSelector(interval)._proxy)));
  
  Observable<T> debounceWithSelector(Observable selector(dynamic value)) => new Observable<T>._internal(_proxy.debounce(selector));
  
  List<Observable<T>> partition(bool predicate(T value)) {
    final List<Rx.Observable> partitions = _proxy.partition(allowInterop((T value, int index, Rx.Observable target) => predicate(value)));
    
    return <Observable<T>>[
      new Observable<T>._internal(partitions.first), 
      new Observable<T>._internal(partitions.last)
    ];
  }
  
  Observable pluck(List<String> path) => map((T value) {
    dynamic currentValue = value;
    
    for (int i=0, len=path.length; i<len; i++) {
      currentValue = currentValue[path[i]];
      
      if (currentValue == null) return null;
    }
    
    return currentValue;
  });
  
  Observable<T> tap(void onListen(T value), {void onError(error), void onCompleted()}) {
    if (onError != null && onCompleted != null)
      return new Observable<T>._internal(_proxy.tap(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted)));
    else if (onError != null)
      return new Observable<T>._internal(_proxy.tap(allowInterop(onListen), allowInterop(onError)));
    
    return new Observable<T>._internal(_proxy.tap(allowInterop(onListen)));
  }
  
  Observable<T> tapWith(Observer<T> observer) => new Observable<T>._internal(_proxy.tap(observer._proxy));
  
  Observable<T> take(int amount, [Scheduler scheduler]) => new Observable<T>._internal(_proxy.take(amount, scheduler?._proxy));
  
  Observable<T> throttle(Duration duration, [Scheduler scheduler]) => new Observable<T>._internal(_proxy.throttle(duration.inMilliseconds, scheduler?._proxy));
  
  Observable<List<T>> toList() => new Observable._internal(_proxy.toArray());
  
  Stream<T> toStream() {
    final StreamController<T> C = new StreamController<T>();
    
    subscribe(
      C.add,
      onError: C.addError,
      onCompleted: C.close
    );
    
    return C.stream.asBroadcastStream();
  }
  
  Observable<Observable<T>> windowWithCount(int count, [int skip]) 
    => new Observable<Rx.Observable>._internal(_proxy.windowWithCount(count, skip))
        .map((Rx.Observable o) => new Observable<T>._internal(o));
  
  Rx.Disposable subscribe(void onListen(T value), {void onError(error), void onCompleted()}) {
    if (onError != null && onCompleted != null)
      return _proxy.subscribe(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted));
    else if (onError != null)
      return _proxy.subscribe(allowInterop(onListen), allowInterop(onError));
    
    return _proxy.subscribe(allowInterop(onListen));
  }
  
  Rx.Disposable subscribeWith(Observer observer) => _proxy.subscribe(observer._proxy);
}