part of rx.core;

Stream bypass(Stream stream, Observable handler(Observable target)) => handler(new Observable.fromStream(stream)).toStream();

class Observable<T> {
  
  final Rx.Observable _proxy;
  
  Observable._internal(this._proxy);
  
  factory Observable.amb(List observablesOrFutures) {
    final List proxies = observablesOrFutures.map((dynamic O) {
      if (O is Observable) return O._proxy;
      else if (O is Future) return new Observable.fromFuture(O)._proxy;
      
      throw new ArgumentError('$O is neither an Observable or a Future');
    }).toList();
    
    return new Observable<T>._internal(context['Rx']['Observable'].callMethod('amb', proxies));
  }
  
  factory Observable.switchCase(String selector(), Map<String, Observable> sources, {Observable elseSource, Scheduler elseScheduler}) {
    final Map<String, Rx.Observable> jsm = <String, Rx.Observable>{};
    
    sources.forEach((String K, Observable O) => jsm.putIfAbsent(K, () => O._proxy));
    
    return new Observable<T>._internal(Rx.Observable.switchCase(
        allowInterop(selector),
        new JsObject.jsify(jsm),
        elseSource?._proxy ?? elseScheduler?._proxy)
    );
  }
  
  factory Observable.combineLatest(List<Observable> observables, [Function resultSelector]) {
    final List proxies = observables.map((Observable O) => O._proxy).toList();
    
    if (resultSelector != null) proxies.add(allowInterop(resultSelector));
    
    return new Observable<T>._internal(context['Rx']['Observable'].callMethod('combineLatest', proxies));
  }
  
  factory Observable.forkJoin(List observablesOrFutures, [Function resultSelector]) {
    final List proxies = observablesOrFutures.map((dynamic O) {
      if (O is Observable) return O._proxy;
      else if (O is Future) return new Observable.fromFuture(O)._proxy;
      
      throw new ArgumentError('$O is neither an Observable or a Future');
    }).toList();
    
    if (resultSelector != null) proxies.add(allowInterop(resultSelector));
    
    return new Observable<T>._internal(context['Rx']['Observable'].callMethod('forkJoin', proxies));
  }
  
  factory Observable.defer(Observable<T> observableFactory ()) => new Observable<T>._internal(Rx.Observable.defer(allowInterop(() => observableFactory()._proxy)));
  
  factory Observable.just(T value) => new Observable<T>._internal(Rx.Observable.just(value));
  
  factory Observable.empty([Scheduler scheduler]) => new Observable<T>._internal(Rx.Observable.empty(scheduler?._proxy));
  
  factory Observable.from(List elements) => new Observable<T>._internal(Rx.Observable.from(elements));
  
  factory Observable.fromEvent(EventTarget eventTarget, String event) => new Observable<T>._internal(Rx.Observable.fromEvent(eventTarget, event));
  
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
  
  factory Observable.interval(Duration period, [Scheduler scheduler]) => new Observable<T>._internal(Rx.Observable.interval(period.inMilliseconds, scheduler?._proxy));
  
  factory Observable.of(List<T> values) => new Observable<T>._internal(context['Rx']['Observable'].callMethod('of', values));
  
  factory Observable.range(int start, int count) => new Observable<T>._internal(Rx.Observable.range(start, count));
  
  factory Observable.repeat(T value, [int repeatCount=-1, Scheduler scheduler]) => new Observable<T>._internal(Rx.Observable.repeat(value, repeatCount, scheduler?._proxy));
  
  factory Observable.timer(Duration interval) => new Observable<T>._internal(Rx.Observable.timer(interval.inMilliseconds));
  
  factory Observable.throwError(Error error, [Scheduler scheduler]) => new Observable<T>._internal(Rx.Observable.throwError(error, scheduler?._proxy));
  
  Observable ambSingle(Observable rightSource) => new Observable._internal(_proxy.amb(rightSource._proxy));
  
  Observable<List<T>> bufferWithCount(int count, [int skip]) => new Observable<List<T>>._internal(_proxy.bufferWithCount(count, skip));
  
  Observable<T> filter(bool predicate(T value)) => new Observable._internal(_proxy.filter(allowInterop((T value, int index, Rx.Observable target) => predicate(value))));
  
  Observable<T> count(bool predicate(T value)) => new Observable._internal(_proxy.count(allowInterop((T value, int index, Rx.Observable target) => predicate(value))));
  
  Observable<T> distinct({dynamic keySelector(T value), bool compare(dynamic a, dynamic b)}) {
    if (keySelector == null && compare == null) return new Observable._internal(_proxy.distinct());
    
    if (compare == null) return new Observable._internal(_proxy.distinct(allowInterop(keySelector)));
    if (keySelector == null) return new Observable._internal(_proxy.distinct(null, allowInterop(compare)));
    
    return new Observable._internal(_proxy.distinct(allowInterop(keySelector), allowInterop(compare)));
  }
  
  Observable<T> distinctUntilChanged({dynamic keySelector(T value), bool compare(dynamic a, dynamic b)}) {
    if (keySelector == null && compare == null) return new Observable._internal(_proxy.distinctUntilChanged());
    
    if (compare == null) return new Observable._internal(_proxy.distinctUntilChanged(allowInterop(keySelector)));
    if (keySelector == null) return new Observable._internal(_proxy.distinctUntilChanged(null, allowInterop(compare)));
    
    return new Observable._internal(_proxy.distinctUntilChanged(allowInterop(keySelector), allowInterop(compare)));
  }
  
  Observable<T> find(bool predicate(T value)) => new Observable._internal(_proxy.find(allowInterop((T value, int index, Rx.Observable target) => predicate(value))));
  
  Observable flatMap(Observable selector(T value)) => new Observable._internal(_proxy.flatMap(allowInterop((T value, int index, Rx.Observable target) => selector(value)._proxy)));
  
  Observable selectMany(Observable selector(T value)) => flatMap(selector);
  
  Observable flatMapLatest(Observable selector(T value)) => new Observable._internal(_proxy.flatMapLatest(allowInterop((T value, int index, Rx.Observable target) => selector(value)._proxy)));
  
  Observable map(dynamic selector(T value)) => new Observable._internal(_proxy.map(allowInterop((T value, int index, Rx.Observable target) => selector(value))));
  
  Observable select(dynamic selector(T value)) => map(selector);
  
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
  
  Observable<T> reduce(T accumulator(dynamic accumulatedValue, T currentValue, int index), [dynamic seed]) => new Observable<T>._internal(_proxy.reduce(allowInterop((dynamic accumulatedValue, dynamic currentValue, dynamic index, Rx.Observable source) => accumulator(accumulatedValue, currentValue, index)), seed));
  
  Observable<T> retry([int retryCount=-1]) => new Observable<T>._internal(_proxy.retry(retryCount));
  
  Observable<T> retryWhen(void onErrors(errors)) => new Observable<T>._internal(_proxy.retryWhen(allowInterop(onErrors)));
  
  Observable<T> scan(T accumulator(dynamic accumulatedValue, T currentValue, int index), [dynamic seed]) => new Observable<T>._internal(_proxy.scan(allowInterop((dynamic accumulatedValue, dynamic currentValue, dynamic index, Rx.Observable source) => accumulator(accumulatedValue, currentValue, index)), seed));
  
  Observable<T> share(Observer<T> observer) => new Observable<T>._internal(_proxy.share());
  
  Observable<T> startWith(List<T> values, {Scheduler scheduler}) {
    final List copy = new List.from(values);
    
    if (scheduler != null) copy.insert(0, scheduler._proxy);
    
    return new Observable<T>._internal((_proxy as JsObject).callMethod('startWith', copy));
  }
  
  Observable<T> tap(void onListen(T value), {void onError(error), void onCompleted()}) {
    if (onError != null && onCompleted != null)
      return new Observable<T>._internal(_proxy.tap(allowInterop(onListen), allowInterop(onError), allowInterop(onCompleted)));
    else if (onError != null)
      return new Observable<T>._internal(_proxy.tap(allowInterop(onListen), allowInterop(onError)));
    
    return new Observable<T>._internal(_proxy.tap(allowInterop(onListen)));
  }
  
  Observable<T> tapWith(Observer<T> observer) => new Observable<T>._internal(_proxy.tap(observer._proxy));
  
  Observable<T> take(int amount, [Scheduler scheduler]) => new Observable<T>._internal(_proxy.take(amount, scheduler?._proxy));
  
  Observable<T> takeUntil(dynamic observableOrFuture) {
    dynamic target;
    
    if (observableOrFuture is Observable) target = observableOrFuture._proxy;
    else if (observableOrFuture is Future) target = new Observable.fromFuture(observableOrFuture)._proxy;
    else throw new ArgumentError('$observableOrFuture is neither an Observable or a Future');
    
    return new Observable<T>._internal(_proxy.takeUntil(target));
  }
  
  Observable<T> throttle(Duration duration, [Scheduler scheduler]) => new Observable<T>._internal(_proxy.throttle(duration.inMilliseconds, scheduler?._proxy));
  
  Observable<TimedEvent<T>> timeInterval([Scheduler scheduler]) => new Observable._internal(_proxy.timeInterval(scheduler?._proxy)).map((jsObject) => new TimedEvent<T>(jsObject['interval'], jsObject['value']));
  
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

class TimedEvent<T> {
  
  final int interval;
  final T value;
  
  TimedEvent(this.interval, this.value);
  
}