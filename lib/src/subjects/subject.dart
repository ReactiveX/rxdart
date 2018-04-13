import 'dart:async';
import 'package:rxdart/futures.dart';
import 'package:rxdart/src/observable.dart';
import 'package:rxdart/src/samplers/buffer_strategy.dart';
import 'package:rxdart/src/transformers/time_interval.dart';
import 'package:rxdart/src/transformers/timestamp.dart';
import 'package:rxdart/src/utils/notification.dart';
import 'package:rxdart/src/utils/type_token.dart';

/// The base for all Subjects. If you'd like to create a new Subject,
/// extend from this class.
///
/// It handles all of the nitty-gritty details that conform to the
/// StreamController spec and don't need to be repeated over and
/// over.
///
/// Please see `PublishSubject` for the simplest example of how to
/// extend from this class, or `BehaviorSubject` for a slightly more
/// complex example.
abstract class Subject<T> implements StreamController<T>, Observable<T> {
  final StreamController<T> controller;
  final Observable<T> observable;
  bool _isAddingStreamItems = false;

  Subject(this.controller, this.observable);

  @override
  Observable<T> get stream => observable;

  @override
  StreamSink<T> get sink => new _StreamSinkWrapper<T>(this);

  @override
  ControllerCallback get onListen => controller.onListen;

  @override
  set onListen(void onListenHandler()) {
    controller.onListen = onListenHandler;
  }

  @override
  ControllerCallback get onPause =>
      throw new UnsupportedError("Subjects do not support pause callbacks");

  @override
  set onPause(void onPauseHandler()) =>
      throw new UnsupportedError("Subjects do not support pause callbacks");

  @override
  ControllerCallback get onResume =>
      throw new UnsupportedError("Subjects do not support resume callbacks");

  @override
  set onResume(void onResumeHandler()) =>
      throw new UnsupportedError("Subjects do not support resume callbacks");

  @override
  ControllerCancelCallback get onCancel => controller.onCancel;

  @override
  set onCancel(void onCancelHandler()) {
    controller.onCancel = onCancelHandler;
  }

  @override
  bool get isClosed => controller.isClosed;

  @override
  bool get isPaused => controller.isPaused;

  @override
  bool get hasListener => controller.hasListener;

  @override
  Future<dynamic> get done => controller.done;

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add an error while items are being added from addStream");
    }

    controller.addError(error, stackTrace);
  }

  @override
  Future<dynamic> addStream(Stream<T> source, {bool cancelOnError: true}) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add items while items are being added from addStream");
    }

    final Completer<T> completer = new Completer<T>();
    _isAddingStreamItems = true;

    source.listen((T event) {
      _add(event);
    }, onError: (dynamic e, StackTrace s) {
      controller.addError(e, s);

      if (cancelOnError) {
        _isAddingStreamItems = false;
        completer.completeError(e);
      }
    }, onDone: () {
      _isAddingStreamItems = false;
      completer.complete();
    }, cancelOnError: cancelOnError);

    return completer.future;
  }

  @override
  void add(T event) {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot add items while items are being added from addStream");
    }

    _add(event);
  }

  void _add(T event) {
    onAdd(event);

    controller.add(event);
  }

  /// An extension point for sub-classes. Perform any side-effect / state
  /// management you need to here, rather than overriding the `add` method
  /// directly.
  void onAdd(T event) {}

  @override
  Future<dynamic> close() {
    if (_isAddingStreamItems) {
      throw new StateError(
          "You cannot close the subject while items are being added from addStream");
    }

    return controller.close();
  }


  @override
  AsObservableFuture<bool> any(bool Function(T element) test) => observable.any(test);

  @override
  Observable<T> asBroadcastStream({void Function(StreamSubscription<T> subscription) onListen, void Function(StreamSubscription<T> subscription) onCancel}) 
                      => observable.asBroadcastStream(onListen: onListen, onCancel: onCancel);
                      
  @override
  Observable<S> asyncExpand<S>(Stream<S> Function(T value) mapper) => observable.asyncExpand(mapper);

  @override
  Observable<S> asyncMap<S>(FutureOr<S> Function(T value) convert) => observable.asyncMap(convert);

  @override
  Observable<List<T>> buffer(SamplerBuilder<T, List<T>> sampler) => buffer(sampler);

  @override
  Observable<List<T>> bufferCount(int count, [int skip]) => bufferCount(count, skip);

  @override
  Observable<List<T>> bufferFuture(Future Function() onFutureHandler) => observable.bufferFuture(onFutureHandler);

  @override
  Observable<List<T>> bufferTest(bool Function(T event) onTestHandler) => observable.bufferTest(onTestHandler);

  @override
  Observable<List<T>> bufferTime(Duration duration) => observable.bufferTime(duration);

  @override
  Observable<List<T>> bufferWhen(Stream other) => bufferWhen(other);

  @override @deprecated
  Observable<List<T>> bufferWithCount(int count, [int skip]) => observable.bufferWithCount(count,skip);

  @override
  Observable<R> cast<R>() => observable.cast<R>();

  @override
  Observable<S> concatMap<S>(Stream<S> Function(T value) mapper) => observable.concatMap(mapper);

  @override
  Observable<T> concatWith(Iterable<Stream<T>> other) => observable.concatWith(other);

  @override
  AsObservableFuture<bool> contains(Object needle) => observable.contains(needle);

  @override
  Observable<T> debounce(Duration duration) => observable.debounce(duration);

  @override
  Observable<T> defaultIfEmpty(T defaultValue) => observable.defaultIfEmpty(defaultValue);

  @override
  Observable<T> delay(Duration duration) => observable.delay(duration);

  @override
  Observable<S> dematerialize<S>() => observable.dematerialize<S>();

  @override
  Observable<T> distinct([bool Function(T previous, T next) equals]) => observable.distinct(equals);

  @override
  Observable<T> distinctUnique({bool Function(T e1, T e2) equals, int Function(T e) hashCode}) => observable.distinctUnique(equals: equals, hashCode: hashCode);

  @override
  Observable<T> doOnCancel(void Function() onCancel) => observable.doOnCancel(onCancel);

  @override
  Observable<T> doOnData(void Function(T event) onData) =>observable.doOnData(onData);

  @override
  Observable<T> doOnDone(void Function() onDone) => observable.doOnDone(onDone);

  @override
  Observable<T> doOnEach(void Function(Notification<T> notification) onEach) => observable.doOnEach(onEach);

  @override
  Observable<T> doOnError(Function onError) => observable.doOnError(onError);

  @override
  Observable<T> doOnListen(void Function() onListen) => observable.doOnListen(onListen);

  @override
  Observable<T> doOnPause(void Function(Future resumeSignal) onPause) => observable.doOnPause(onPause);

  @override
  Observable<T> doOnResume(void Function() onResume) => observable.doOnResume(onResume);

  @override
  AsObservableFuture<S> drain<S>([S futureValue]) => observable.drain<S>(futureValue);

  @override
  AsObservableFuture<T> elementAt(int index) => observable.elementAt(index);

  @override
  AsObservableFuture<bool> every(bool Function(T element) test) => observable.every(test);

  @override
  Observable<S> exhaustMap<S>(Stream<S> Function(T value) mapper) => observable.exhaustMap(mapper);

  @override
  Observable<S> expand<S>(Iterable<S> Function(T value) convert) => observable.expand(convert);

  // TODO: implement first
  @override
  AsObservableFuture<T> get first => observable.first;

  @override
  AsObservableFuture<T> firstWhere(bool Function(T element) test, {dynamic Function() defaultValue, T Function() orElse}) =>
                            observable.firstWhere(test,orElse: orElse);

  @override
  Observable<S> flatMap<S>(Stream<S> Function(T value) mapper) => observable.flatMap(mapper);

  @override @deprecated
  Observable<S> flatMapLatest<S>(Stream<S> Function(T value) mapper) => observable.flatMapLatest(mapper);

  @override
  AsObservableFuture<S> fold<S>(S initialValue, S Function(S previous, T element) combine) => observable.fold(initialValue, combine);

  @override
  AsObservableFuture forEach(void Function(T element) action) => observable.forEach(action);

  @override
  Observable<T> handleError(Function onError, {bool Function(dynamic error) test}) => observable.handleError(onError);

  @override
  Observable<T> ignoreElements() => observable.ignoreElements();

  @override
  Observable<T> interval(Duration duration) => observable.interval(duration);

  // TODO: implement isBroadcast
  @override
  bool get isBroadcast => observable.isBroadcast;

  // TODO: implement isEmpty
  @override
  AsObservableFuture<bool> get isEmpty => observable.isEmpty;

  @override
  AsObservableFuture<String> join([String separator = ""]) => observable.join(separator);

  // TODO: implement last
  @override
  AsObservableFuture<T> get last => observable.last;

  @override
  AsObservableFuture<T> lastWhere(bool Function(T element) test, {Object Function() defaultValue, T Function() orElse}) =>
                            observable.lastWhere(test,defaultValue: defaultValue, orElse: orElse);

  // TODO: implement length
  @override
  AsObservableFuture<int> get length => observable.length;

  @override
  StreamSubscription<T> listen(void Function(T event) onData, {Function onError, void Function() onDone, bool cancelOnError}) =>
                            observable.listen(onData,onError: onError, cancelOnError: cancelOnError, onDone: onDone);

  @override
  Observable<S> map<S>(S Function(T event) convert) => observable.map(convert);

  @override
  Observable<Notification<T>> materialize() => observable.materialize();

  @override
  AsObservableFuture<T> max([Comparator<T> comparator]) => observable.max(comparator);

  @override
  Observable<T> mergeWith(Iterable<Stream<T>> streams) => observable.mergeWith(streams);

  @override
  AsObservableFuture<T> min([Comparator<T> comparator]) => observable.min(comparator);

  @override
  Observable<S> ofType<S>(TypeToken<S> typeToken) => observable.ofType(typeToken);

  @override
  Observable<T> onErrorResumeNext(Stream<T> recoveryStream) => observable.onErrorResumeNext(recoveryStream);

  @override
  Observable<T> onErrorReturn(T returnValue) => observable.onErrorReturn(returnValue);

  @override
  AsObservableFuture pipe(StreamConsumer<T> streamConsumer) => observable.pipe(streamConsumer);

  @override
  AsObservableFuture<T> reduce(T Function(T previous, T element) combine) => observable.reduce(combine);

  @override
  Observable<T> repeat(int repeatCount) => observable.repeat(repeatCount);

  @override
  Observable<R> retype<R>() => observable.retype<R>();

  @override
  Observable<T> sample(Stream sampleStream) => observable.sample(sampleStream);

  @override
  Observable<S> scan<S>(S Function(S accumulated, T value, int index) accumulator, [S seed]) =>
                  observable.scan<S>(accumulator, seed);

  // TODO: implement single
  @override
  AsObservableFuture<T> get single => observable.single;

  @override
  AsObservableFuture<T> singleWhere(bool Function(T element) test, {T Function() orElse}) =>
                            observable.singleWhere(test, orElse: orElse);

  @override
  Observable<T> skip(int count) => observable.skip(count);

  @override
  Observable<T> skipUntil<S>(Stream<S> otherStream) => skipUntil(otherStream);

  @override
  Observable<T> skipWhile(bool Function(T element) test) => observable.skipWhile(test);

  @override
  Observable<T> startWith(T startValue) => observable.startWith(startValue);

  @override
  Observable<T> startWithMany(List<T> startValues) => observable.startWithMany(startValues);

  @override
  Observable<T> switchIfEmpty(Stream<T> fallbackStream) => observable.switchIfEmpty(fallbackStream);

  @override
  Observable<S> switchMap<S>(Stream<S> Function(T value) mapper) => observable.switchMap(mapper);

  @override
  Observable<T> take(int count) => observable.take(count);

  @override
  Observable<T> takeUntil<S>(Stream<S> otherStream) => observable.takeUntil<S>(otherStream);

  @override
  Observable<T> takeWhile(bool Function(T element) test) => observable.takeWhile(test);

  @override
  Observable<T> throttle(Duration duration) => observable.throttle(duration);

  @override
  Observable<TimeInterval<T>> timeInterval() => observable.timeInterval();

  @override
  Observable<T> timeout(Duration timeLimit, {void Function(EventSink<T> sink) onTimeout}) => observable.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Observable<Timestamped<T>> timestamp() => observable.timestamp();

  @override
  AsObservableFuture<List<T>> toList() => observable.toList();

  @override
  AsObservableFuture<Set<T>> toSet() => observable.toSet();

  @override
  Observable<S> transform<S>(StreamTransformer<T, S> streamTransformer) => observable.transform(streamTransformer);

  @override
  Observable<T> where(bool Function(T event) test) => observable.where(test);

  @override
  Observable<Stream<T>> window(SamplerBuilder<T, Stream<T>> sampler) =>observable.window(sampler);

  @override
  Observable<Stream<T>> windowCount(int count, [int skip]) => observable.windowCount(count, skip);

  @override
  Observable<Stream<T>> windowFuture(Future Function() onFutureHandler) => observable.windowFuture(onFutureHandler);

  @override
  Observable<Stream<T>> windowTest(bool Function(T event) onTestHandler) => observable.windowTest(onTestHandler);

  @override
  Observable<Stream<T>> windowTime(Duration duration) => observable.windowTime(duration);

  @override
  Observable<Stream<T>> windowWhen(Stream other) => observable.windowWhen(other);

  @override  @deprecated
  Observable<Stream<T>> windowWithCount(int count, [int skip]) => observable.windowWithCount(count, skip);

  @override
  Observable<R> withLatestFrom<S, R>(Stream<S> latestFromStream, R Function(T t, S s) fn) => observable.withLatestFrom(latestFromStream, fn);

  @override
  Observable<R> zipWith<S, R>(Stream<S> other, R Function(T t, S s) zipper) => observable.zipWith(other, zipper);
  
}

class _StreamSinkWrapper<T> implements StreamSink<T> {
  final StreamController<T> _target;
  _StreamSinkWrapper(this._target);

  @override
  void add(T data) {
    _target.add(data);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _target.addError(error, stackTrace);
  }

  @override
  Future close() => _target.close();

  @override
  Future addStream(Stream<T> source) => _target.addStream(source);

  @override
  Future get done => _target.done;



  
}
