import 'dart:async';

import 'package:rxdart/streams.dart';
import 'package:rxdart/transformers.dart';

import 'observables/connectable_observable.dart';
import 'observables/replay_observable.dart';
import 'observables/value_observable.dart';

extension ObservableExtensions<T> on Stream<T> {
  /// Creates a Stream where each item is a [List] containing the items
  /// from the source sequence.
  ///
  /// This [List] is emitted every time [window] emits an event.
  ///
  /// ### Example
  ///
  ///     Stream.periodic(Duration(milliseconds: 100), (i) => i)
  ///       .buffer(Stream.periodic(Duration(milliseconds: 160), (i) => i))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  Stream<List<T>> buffer(Stream window) =>
      transform(BufferStreamTransformer((_) => window));

  /// Buffers a number of values from the source Stream by [count] then
  /// emits the buffer and clears it, and starts a new buffer each
  /// [startBufferEvery] values. If [startBufferEvery] is not provided,
  /// then new buffers are started immediately at the start of the source
  /// and when each buffer closes and is emitted.
  ///
  /// ### Example
  /// [count] is the maximum size of the buffer emitted
  ///
  ///     RangeStream(1, 4)
  ///       .bufferCount(2)
  ///       .listen(print); // prints [1, 2], [3, 4] done!
  ///
  /// ### Example
  /// if [startBufferEvery] is 2, then a new buffer will be started
  /// on every other value from the source. A new buffer is started at the
  /// beginning of the source by default.
  ///
  ///     RangeStream(1, 5)
  ///       .bufferCount(3, 2)
  ///       .listen(print); // prints [1, 2, 3], [3, 4, 5], [5] done!
  Stream<List<T>> bufferCount(int count, [int startBufferEvery = 0]) =>
      transform(BufferCountStreamTransformer<T>(count, startBufferEvery));

  /// Creates a Stream where each item is a [List] containing the items
  /// from the source sequence, batched whenever test passes.
  ///
  /// ### Example
  ///
  ///     Stream.periodic(Duration(milliseconds: 100), (int i) => i)
  ///       .bufferTest((i) => i % 2 == 0)
  ///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
  Stream<List<T>> bufferTest(bool onTestHandler(T event)) =>
      transform(BufferTestStreamTransformer<T>(onTestHandler));

  /// Creates a Stream where each item is a [List] containing the items
  /// from the source sequence, sampled on a time frame with [duration].
  ///
  /// ### Example
  ///
  ///     Stream.periodic(Duration(milliseconds: 100), (int i) => i)
  ///       .bufferTime(Duration(milliseconds: 220))
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  Stream<List<T>> bufferTime(Duration duration) {
    if (duration == null) throw ArgumentError.notNull('duration');

    return buffer(Stream<void>.periodic(duration));
  }

  /// Maps each emitted item to a new [Stream] using the given mapper, then
  /// subscribes to each new stream one after the next until all values are
  /// emitted.
  ///
  /// ConcatMap is similar to flatMap, but ensures order by guaranteeing that
  /// all items from the created stream will be emitted before moving to the
  /// next created stream. This process continues until all created streams have
  /// completed.
  ///
  /// This is a simple alias for Dart Stream's `asyncExpand`, but is included to
  /// ensure a more consistent Rx API.
  ///
  /// ### Example
  ///
  ///     Observable.range(4, 1)
  ///       .concatMap((i) =>
  ///         new Observable.timer(i, new Duration(minutes: i))
  ///       .listen(print); // prints 4, 3, 2, 1
  Stream<S> concatMap<S>(Stream<S> mapper(T value)) => asyncExpand(mapper);

  /// Returns a Stream that emits all items from the current Stream,
  /// then emits all items from the given streams, one after the next.
  ///
  /// ### Example
  ///
  ///     TimerStream(1, Duration(seconds: 10))
  ///         .concatWith([Stream.fromIterable([2])])
  ///         .listen(print); // prints 1, 2
  Stream<T> concatWith(Iterable<Stream<T>> other) =>
      ConcatStream<T>([this, ...other]);

  /// Transforms a [Stream] so that will only emit items from the source sequence
  /// if a [window] has completed, without the source sequence emitting
  /// another item.
  ///
  /// This [window] is created after the last debounced event was emitted.
  /// You can use the value of the last debounced event to determine
  /// the length of the next [window].
  ///
  /// A [window] is open until the first [window] event emits.
  ///
  /// debounce filters out items emitted by the source [Stream]
  /// that are rapidly followed by another emitted item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#debounce)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4])
  ///       .debounce((_) => TimerStream(true, Duration(seconds: 1)))
  ///       .listen(print); // prints 4
  Stream<T> debounce(Stream window(T event)) =>
      transform(DebounceStreamTransformer<T>(window));

  /// Transforms a [Stream] so that will only emit items from the source
  /// sequence whenever the time span defined by [duration] passes, without the
  /// source sequence emitting another item.
  ///
  /// This time span start after the last debounced event was emitted.
  ///
  /// debounceTime filters out items emitted by the source [Stream] that are
  /// rapidly followed by another emitted item.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#debounce)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4])
  ///       .debounceTime(Duration(seconds: 1))
  ///       .listen(print); // prints 4
  Stream<T> debounceTime(Duration duration) => transform(
      DebounceStreamTransformer<T>((_) => TimerStream<bool>(true, duration)));

  /// Emit items from the source Stream, or a single default item if the source
  /// Stream emits nothing.
  ///
  /// ### Example
  ///
  ///     Stream.empty().defaultIfEmpty(10).listen(print); // prints 10
  Stream<T> defaultIfEmpty(T defaultValue) =>
      transform(DefaultIfEmptyStreamTransformer<T>(defaultValue));

  /// The Delay operator modifies its source Stream by pausing for a particular
  /// increment of time (that you specify) before emitting each of the source
  /// Stream’s items. This has the effect of shifting the entire sequence of
  /// items emitted by the Stream forward in time by that specified increment.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#delay)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4])
  ///       .delay(Duration(seconds: 1))
  ///       .listen(print); // [after one second delay] prints 1, 2, 3, 4 immediately
  Stream<T> delay(Duration duration) =>
      transform(DelayStreamTransformer<T>(duration));

  /// Converts the onData, onDone, and onError [Notification] objects from a
  /// materialized stream into normal onData, onDone, and onError events.
  ///
  /// When a stream has been materialized, it emits onData, onDone, and onError
  /// events as [Notification] objects. Dematerialize simply reverses this by
  /// transforming [Notification] objects back to a normal stream of events.
  ///
  /// ### Example
  ///
  ///     Stream<Notification<int>>
  ///         .fromIterable([Notification.onData(1), Notification.onDone()])
  ///         .dematerialize()
  ///         .listen((i) => print(i)); // Prints 1
  ///
  /// ### Error example
  ///
  ///     Stream<Notification<int>>
  ///         .fromIterable([Notification.onError(new Exception(), null)])
  ///         .dematerialize()
  ///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
  Stream<S> dematerialize<S>() {
    return cast<Notification<S>>()
        .transform(DematerializeStreamTransformer<S>());
  }

  /// WARNING: More commonly known as distinct in other Rx implementations.
  /// Creates a Stream where data events are skipped if they have already
  /// been emitted before.
  ///
  /// Equality is determined by the provided equals and hashCode methods.
  /// If these are omitted, the '==' operator and hashCode on the last provided
  /// data element are used.
  ///
  /// The returned stream is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually perform the equals and hashCode tests.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#distinct)
  Stream<T> distinctUnique({bool equals(T e1, T e2), int hashCode(T e)}) =>
      transform(DistinctUniqueStreamTransformer<T>(
          equals: equals, hashCode: hashCode));

  /// Invokes the given callback function when the stream subscription is
  /// cancelled. Often called doOnUnsubscribe or doOnDispose in other
  /// implementations.
  ///
  /// ### Example
  ///
  ///     final subscription = TimerStream(1, Duration(minutes: 1))
  ///       .doOnCancel(() => print("hi"));
  ///       .listen(null);
  ///
  ///     subscription.cancel(); // prints "hi"
  Stream<T> doOnCancel(void onCancel()) =>
      transform(DoStreamTransformer<T>(onCancel: onCancel));

  /// Invokes the given callback function when the stream emits an item. In
  /// other implementations, this is called doOnNext.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .doOnData(print)
  ///       .listen(null); // prints 1, 2, 3
  Stream<T> doOnData(void onData(T event)) =>
      transform(DoStreamTransformer<T>(onData: onData));

  /// Invokes the given callback function when the stream finishes emitting
  /// items. In other implementations, this is called doOnComplete(d).
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .doOnDone(() => print("all set"))
  ///       .listen(null); // prints "all set"
  Stream<T> doOnDone(void onDone()) =>
      transform(DoStreamTransformer<T>(onDone: onDone));

  /// Invokes the given callback function when the stream emits data, emits
  /// an error, or emits done. The callback receives a [Notification] object.
  ///
  /// The [Notification] object contains the [Kind] of event (OnData, onDone,
  /// or OnError), and the item or error that was emitted. In the case of
  /// onDone, no data is emitted as part of the [Notification].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///       .doOnEach(print)
  ///       .listen(null); // prints Notification{kind: OnData, value: 1, errorAndStackTrace: null}, Notification{kind: OnDone, value: null, errorAndStackTrace: null}
  Stream<T> doOnEach(void onEach(Notification<T> notification)) =>
      transform(DoStreamTransformer<T>(onEach: onEach));

  /// Invokes the given callback function when the stream emits an error.
  ///
  /// ### Example
  ///
  ///     Stream.error(new Exception())
  ///       .doOnError((error, stacktrace) => print("oh no"))
  ///       .listen(null); // prints "Oh no"
  Stream<T> doOnError(Function onError) =>
      transform(DoStreamTransformer<T>(onError: onError));

  /// Invokes the given callback function when the stream is first listened to.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///       .doOnListen(() => print("Is someone there?"))
  ///       .listen(null); // prints "Is someone there?"
  Stream<T> doOnListen(void onListen()) =>
      transform(DoStreamTransformer<T>(onListen: onListen));

  /// Invokes the given callback function when the stream subscription is
  /// paused.
  ///
  /// ### Example
  ///
  ///     final subscription = Stream.fromIterable([1])
  ///       .doOnPause(() => print("Gimme a minute please"))
  ///       .listen(null);
  ///
  ///     subscription.pause(); // prints "Gimme a minute please"
  Stream<T> doOnPause(void onPause(Future<dynamic> resumeSignal)) =>
      transform(DoStreamTransformer<T>(onPause: onPause));

  /// Invokes the given callback function when the stream subscription
  /// resumes receiving items.
  ///
  /// ### Example
  ///
  ///     final subscription = Stream.fromIterable([1])
  ///       .doOnResume(() => print("Let's do this!"))
  ///       .listen(null);
  ///
  ///     subscription.pause();
  ///     subscription.resume(); "Let's do this!"
  Stream<T> doOnResume(void onResume()) =>
      transform(DoStreamTransformer<T>(onResume: onResume));

  /// Converts items from the source stream into a Stream using a given
  /// mapper. It ignores all items from the source stream until the new stream
  /// completes.
  ///
  /// Useful when you have a noisy source Stream and only want to respond once
  /// the previous async operation is finished.
  ///
  /// ### Example
  ///
  ///     RangeStream(0, 2).interval(Duration(milliseconds: 50))
  ///       .exhaustMap((i) =>
  ///         TimerStream(i, Duration(milliseconds: 75)))
  ///       .listen(print); // prints 0, 2
  Stream<S> exhaustMap<S>(Stream<S> mapper(T value)) =>
      transform(ExhaustMapStreamTransformer<T, S>(mapper));

  /// Converts each emitted item into a Stream using the given mapper
  /// function. The newly created Stream will be be listened to and begin
  /// emitting items downstream.
  ///
  /// The items emitted by each of the Streams are emitted downstream in the
  /// same order they arrive. In other words, the sequences are merged
  /// together.
  ///
  /// ### Example
  ///
  ///     RangeStream(4, 1)
  ///       .flatMap((i) =>
  ///         TimerStream(i, Duration(minutes: i))
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<S> flatMap<S>(Stream<S> mapper(T value)) =>
      transform(FlatMapStreamTransformer<T, S>(mapper));

  /// Converts each item into a Stream. The Stream must return an
  /// Iterable. Then, each item from the Iterable will be emitted one by one.
  ///
  /// Use case: you may have an API that returns a list of items, such as
  /// a Stream<List<String>>. However, you might want to operate on the individual items
  /// rather than the list itself. This is the job of `flatMapIterable`.
  ///
  /// ### Example
  ///
  ///     RangeStream(1, 4)
  ///       .flatMapIterable((i) =>
  ///         Stream.fromIterable([[]i])
  ///       .listen(print); // prints 1, 2, 3, 4
  Stream<S> flatMapIterable<S>(Stream<Iterable<S>> mapper(T value)) =>
      transform(FlatMapStreamTransformer<T, Iterable<S>>(mapper))
          .expand((Iterable<S> iterable) => iterable);

  /// The GroupBy operator divides an [Stream] that emits items into an [Stream]
  /// that emits [GroupByStream], each one of which emits some subset of the
  /// items from the original source [Stream].
  ///
  /// [GroupByStream] acts like a regular [Stream], yet adding a 'key' property,
  /// which receives its [Type] and value from the [grouper] Function.
  ///
  /// All items with the same key are emitted by the same [GroupByStream].
  Stream<GroupByObservable<T, S>> groupBy<S>(S grouper(T value)) =>
      transform(GroupByStreamTransformer<T, S>(grouper));

  /// Creates a Stream where all emitted items are ignored, only the error /
  /// completed notifications are passed
  ///
  /// ### Example
  ///
  ///    MergeStream([
  ///      Stream.fromIterable([1]),
  ///      Stream.error(new Exception())
  ///    ])
  ///    .listen(print, onError: print); // prints Exception
  Stream<T> ignoreElements() => transform(IgnoreElementsStreamTransformer<T>());

  /// Creates a Stream that emits each item in the Stream after a given
  /// duration.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .interval(Duration(seconds: 1))
  ///       .listen((i) => print("$i sec"); // prints 1 sec, 2 sec, 3 sec
  Stream<T> interval(Duration duration) =>
      transform(IntervalStreamTransformer<T>(duration));

  /// Emits the given constant value on the output Stream every time the source
  /// Stream emits a value.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3, 4])
  ///       .mapTo(true)
  ///       .listen(print); // prints true, true, true, true
  Stream<S> mapTo<S>(S value) => transform(MapToStreamTransformer<T, S>(value));

  /// Converts the onData, on Done, and onError events into [Notification]
  /// objects that are passed into the downstream onData listener.
  ///
  /// The [Notification] object contains the [Kind] of event (OnData, onDone, or
  /// OnError), and the item or error that was emitted. In the case of onDone,
  /// no data is emitted as part of the [Notification].
  ///
  /// Example:
  ///     Stream<int>.fromIterable([1])
  ///         .materialize()
  ///         .listen((i) => print(i)); // Prints onData & onDone Notification
  ///
  ///     Stream<int>.error(new Exception())
  ///         .materialize()
  ///         .listen((i) => print(i)); // Prints onError Notification
  Stream<Notification<T>> materialize() =>
      transform(MaterializeStreamTransformer<T>());

  /// Converts a Stream into a Future that completes with the largest item
  /// emitted by the Stream.
  ///
  /// This is similar to finding the max value in a list, but the values are
  /// asynchronous.
  ///
  /// ### Example
  ///
  ///     final max = await Stream.fromIterable([1, 2, 3]).max();
  ///
  ///     print(max); // prints 3
  ///
  /// ### Example with custom [Comparator]
  ///
  ///     final stream = Stream.fromIterable(["short", "looooooong"]);
  ///     final max = await stream.max((a, b) => a.length - b.length);
  ///
  ///     print(max); // prints "looooooong"
  Future<T> max([Comparator<T> comparator]) =>
      toList().then((List<T> values) => (values..sort(comparator)).last);

  /// Combines the items emitted by multiple streams into a single stream of
  /// items. The items are emitted in the order they are emitted by their
  /// sources.
  ///
  /// ### Example
  ///
  ///     TimerStream(1, Duration(seconds: 10))
  ///         .mergeWith([Stream.fromIterable([2])])
  ///         .listen(print); // prints 2, 1
  Stream<T> mergeWith(Iterable<Stream<T>> streams) =>
      MergeStream<T>([this, ...streams]);

  /// Converts a Stream into a Future that completes with the smallest item
  /// emitted by the Stream.
  ///
  /// This is similar to finding the min value in a list, but the values are
  /// asynchronous!
  ///
  /// ### Example
  ///
  ///     final min = await Stream.fromIterable([1, 2, 3]).min();
  ///
  ///     print(min); // prints 1
  ///
  /// ### Example with custom [Comparator]
  ///
  ///     final stream = Stream.fromIterable(["short", "looooooong"]);
  ///     final min = await stream.min((a, b) => a.length - b.length);
  ///
  ///     print(min); // prints "short"
  Future<T> min([Comparator<T> comparator]) =>
      toList().then((List<T> values) => (values..sort(comparator)).first);

  /// Intercepts error events and switches to the given recovery stream in
  /// that case
  ///
  /// The onErrorResumeNext operator intercepts an onError notification from
  /// the source Stream. Instead of passing the error through to any
  /// listeners, it replaces it with another Stream of items.
  ///
  /// If you need to perform logic based on the type of error that was emitted,
  /// please consider using [onErrorResume].
  ///
  /// ### Example
  ///
  ///     ErrorStream(new Exception())
  ///       .onErrorResumeNext(Stream.fromIterable([1, 2, 3]))
  ///       .listen(print); // prints 1, 2, 3
  Stream<T> onErrorResumeNext(Stream<T> recoveryStream) => transform(
      OnErrorResumeStreamTransformer<T>((dynamic e) => recoveryStream));

  /// Intercepts error events and switches to a recovery stream created by the
  /// provided [recoveryFn].
  ///
  /// The onErrorResume operator intercepts an onError notification from
  /// the source Stream. Instead of passing the error through to any
  /// listeners, it replaces it with another Stream of items created by the
  /// [recoveryFn].
  ///
  /// The [recoveryFn] receives the emitted error and returns a Stream. You can
  /// perform logic in the [recoveryFn] to return different Streams based on the
  /// type of error that was emitted.
  ///
  /// If you do not need to perform logic based on the type of error that was
  /// emitted, please consider using [onErrorResumeNext] or [onErrorReturn].
  ///
  /// ### Example
  ///
  ///     ErrorStream(new Exception())
  ///       .onErrorResume((dynamic e) =>
  ///           Stream.fromIterable([e is StateError ? 1 : 0])
  ///       .listen(print); // prints 0
  Stream<T> onErrorResume(Stream<T> Function(dynamic error) recoveryFn) =>
      transform(OnErrorResumeStreamTransformer<T>(recoveryFn));

  /// instructs a Stream to emit a particular item when it encounters an
  /// error, and then terminate normally
  ///
  /// The onErrorReturn operator intercepts an onError notification from
  /// the source Stream. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// If you need to perform logic based on the type of error that was emitted,
  /// please consider using [onErrorReturnWith].
  ///
  /// ### Example
  ///
  ///     ErrorStream(new Exception())
  ///       .onErrorReturn(1)
  ///       .listen(print); // prints 1
  Stream<T> onErrorReturn(T returnValue) =>
      transform(OnErrorResumeStreamTransformer<T>(
          (dynamic e) => Stream<T>.fromIterable([returnValue])));

  /// instructs a Stream to emit a particular item created by the
  /// [returnFn] when it encounters an error, and then terminate normally.
  ///
  /// The onErrorReturnWith operator intercepts an onError notification from
  /// the source Stream. Instead of passing it through to any observers, it
  /// replaces it with a given item, and then terminates normally.
  ///
  /// The [returnFn] receives the emitted error and returns a Stream. You can
  /// perform logic in the [returnFn] to return different Streams based on the
  /// type of error that was emitted.
  ///
  /// If you do not need to perform logic based on the type of error that was
  /// emitted, please consider using [onErrorReturn].
  ///
  /// ### Example
  ///
  ///     ErrorStream(new Exception())
  ///       .onErrorReturnWith((e) => e is Exception ? 1 : 0)
  ///       .listen(print); // prints 1
  Stream<T> onErrorReturnWith(T Function(dynamic error) returnFn) =>
      transform(OnErrorResumeStreamTransformer<T>(
          (dynamic e) => Stream<T>.fromIterable([returnFn(e)])));

  /// Emits the n-th and n-1th events as a pair..
  ///
  /// ### Example
  ///
  ///     RangeStream(1, 4)
  ///       .pairwise()
  ///       .listen(print); // prints [1, 2], [2, 3], [3, 4]
  Stream<Iterable<T>> pairwise() => transform(PairwiseStreamTransformer());

  /// Emits the most recently emitted item (if any)
  /// emitted by the source [Stream] since the previous emission from
  /// the [sampleStream].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .sample(new TimerStream(1, Duration(seconds: 1)))
  ///       .listen(print); // prints 3
  Stream<T> sample(Stream<dynamic> sampleStream) =>
      transform(SampleStreamTransformer<T>((_) => sampleStream));

  /// Emits the most recently emitted item (if any) emitted by the source
  /// [Stream] since the previous emission within the recurring time span,
  /// defined by [duration]
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .sampleTime(Duration(seconds: 1))
  ///       .listen(print); // prints 3
  Stream<T> sampleTime(Duration duration) =>
      sample(Stream<void>.periodic(duration));

  /// Applies an accumulator function over a Stream sequence and returns each
  /// intermediate result. The optional seed value is used as the initial
  /// accumulator value.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///        .scan((acc, curr, i) => acc + curr, 0)
  ///        .listen(print); // prints 1, 3, 6
  Stream<S> scan<S>(
    S accumulator(S accumulated, T value, int index), [
    S seed,
  ]) =>
      transform(ScanStreamTransformer<T, S>(accumulator, seed));

  /// Starts emitting items only after the given stream emits an item.
  ///
  /// ### Example
  ///
  ///     MergeStream([
  ///         Stream.fromIterable([1]),
  ///         TimerStream(2, Duration(minutes: 2))
  ///       ])
  ///       .skipUntil(TimerStream(true, Duration(minutes: 1)))
  ///       .listen(print); // prints 2;
  Stream<T> skipUntil<S>(Stream<S> otherStream) =>
      transform(SkipUntilStreamTransformer<T, S>(otherStream));

  /// Prepends a value to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2]).startWith(1).listen(print); // prints 1, 2
  Stream<T> startWith(T startValue) =>
      transform(StartWithStreamTransformer<T>(startValue));

  /// Prepends a sequence of values to the source Stream.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([3]).startWithMany([1, 2])
  ///       .listen(print); // prints 1, 2, 3
  Stream<T> startWithMany(List<T> startValues) =>
      transform(StartWithManyStreamTransformer<T>(startValues));

  /// When the original Stream emits no items, this operator subscribes to the
  /// given fallback stream and emits items from that Stream instead.
  ///
  /// This can be particularly useful when consuming data from multiple sources.
  /// For example, when using the Repository Pattern. Assuming you have some
  /// data you need to load, you might want to start with the fastest access
  /// point and keep falling back to the slowest point. For example, first query
  /// an in-memory database, then a database on the file system, then a network
  /// call if the data isn't on the local machine.
  ///
  /// This can be achieved quite simply with switchIfEmpty!
  ///
  /// ### Example
  ///
  ///     // Let's pretend we have some Data sources that complete without
  ///     // emitting any items if they don't contain the data we're looking for
  ///     Stream<Data> memory;
  ///     Stream<Data> disk;
  ///     Stream<Data> network;
  ///
  ///     // Start with memory, fallback to disk, then fallback to network.
  ///     // Simple as that!
  ///     Stream<Data> getThatData =
  ///         memory.switchIfEmpty(disk).switchIfEmpty(network);
  Stream<T> switchIfEmpty(Stream<T> fallbackStream) =>
      transform(SwitchIfEmptyStreamTransformer<T>(fallbackStream));

  /// Converts each emitted item into a Stream using the given mapper function.
  /// The newly created Stream will be be listened to and begin emitting items,
  /// and any previously created Stream will stop emitting.
  ///
  /// The switchMap operator is similar to the flatMap and concatMap methods,
  /// but it only emits items from the most recently created Stream.
  ///
  /// This can be useful when you only want the very latest state from
  /// asynchronous APIs, for example.
  ///
  /// ### Example
  ///
  ///     RangeStream(4, 1)
  ///       .switchMap((i) =>
  ///         TimerStream(i, Duration(minutes: i))
  ///       .listen(print); // prints 1
  Stream<S> switchMap<S>(Stream<S> mapper(T value)) =>
      transform(SwitchMapStreamTransformer<T, S>(mapper));

  /// Returns the values from the source Stream sequence until the other Stream
  /// sequence produces a value.
  ///
  /// ### Example
  ///
  ///     MergeStream([
  ///         Stream.fromIterable([1]),
  ///         TimerStream(2, Duration(minutes: 1))
  ///       ])
  ///       .takeUntil(TimerStream(3, Duration(seconds: 10)))
  ///       .listen(print); // prints 1
  Stream<T> takeUntil<S>(Stream<S> otherStream) =>
      transform(TakeUntilStreamTransformer<T, S>(otherStream));

  /// Emits only the first item emitted by the source [Stream] while [window] is
  /// open.
  ///
  /// if [trailing] is true, then the last item is emitted instead
  ///
  /// You can use the value of the last throttled event to determine the length
  /// of the next [window].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .throttle((_) => TimerStream(true, Duration(seconds: 1)))
  Stream<T> throttle(Stream window(T event), {bool trailing = false}) =>
      transform(ThrottleStreamTransformer<T>(window, trailing: trailing));

  /// Emits only the first item emitted by the source [Stream] within a time
  /// span of [duration].
  ///
  /// if [trailing] is true, then the last item is emitted instead
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2, 3])
  ///       .throttleTime(Duration(seconds: 1))
  Stream<T> throttleTime(Duration duration, {bool trailing = false}) =>
      transform(ThrottleStreamTransformer<T>(
          (_) => TimerStream<bool>(true, duration),
          trailing: trailing));

  /// Records the time interval between consecutive values in a Stream sequence.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///       .interval(Duration(seconds: 1))
  ///       .timeInterval()
  ///       .listen(print); // prints TimeInterval{interval: 0:00:01, value: 1}
  Stream<TimeInterval<T>> timeInterval() =>
      transform(TimeIntervalStreamTransformer<T>());

  /// Wraps each item emitted by the source Stream in a [Timestamped] object
  /// that includes the emitted item and the time when the item was emitted.
  ///
  /// Example
  ///
  ///     Stream.fromIterable([1])
  ///        .timestamp()
  ///        .listen((i) => print(i)); // prints 'TimeStamp{timestamp: XXX, value: 1}';
  Stream<Timestamped<T>> timestamp() =>
      transform(TimestampStreamTransformer<T>());

  /// This transformer is a shorthand for [Stream.where] followed by
  /// [Stream.cast].
  ///
  /// Events that do not match [T] are filtered out, the resulting [Stream] will
  /// be of Type [T].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 'two', 3, 'four'])
  ///       .whereType<int>()
  ///       .listen(print); // prints 1, 3
  ///
  /// #### as opposed to:
  ///
  ///     Stream.fromIterable([1, 'two', 3, 'four'])
  ///       .where((event) => event is int)
  ///       .cast<int>()
  ///       .listen(print); // prints 1, 3
  Stream<S> whereType<S>() => transform(WhereTypeStreamTransformer<T, S>());

  /// Creates a Stream where each item is a [Stream] containing the items from
  /// the source sequence.
  ///
  /// This [List] is emitted every time [window] emits an event.
  ///
  /// ### Example
  ///
  ///     Stream.periodic(Duration(milliseconds: 100), (i) => i)
  ///       .window(Stream.periodic(Duration(milliseconds: 160), (i) => i))
  ///       .asyncMap((stream) => stream.toList())
  ///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
  Stream<Stream<T>> window(Stream window) =>
      transform(WindowStreamTransformer((_) => window));

  /// Buffers a number of values from the source Stream by [count] then emits
  /// the buffer as a [Stream] and clears it, and starts a new buffer each
  /// [startBufferEvery] values. If [startBufferEvery] is not provided, then new
  /// buffers are started immediately at the start of the source and when each
  /// buffer closes and is emitted.
  ///
  /// ### Example
  /// [count] is the maximum size of the buffer emitted
  ///
  ///     RangeStream(1, 4)
  ///       .windowCount(2)
  ///       .asyncMap((stream) => stream.toList())
  ///       .listen(print); // prints [1, 2], [3, 4] done!
  ///
  /// ### Example
  /// if [startBufferEvery] is 2, then a new buffer will be started
  /// on every other value from the source. A new buffer is started at the
  /// beginning of the source by default.
  ///
  ///     RangeStream(1, 5)
  ///       .bufferCount(3, 2)
  ///       .listen(print); // prints [1, 2, 3], [3, 4, 5], [5] done!
  Stream<Stream<T>> windowCount(int count, [int startBufferEvery = 0]) =>
      transform(WindowCountStreamTransformer(count, startBufferEvery));

  /// Creates a Stream where each item is a [Stream] containing the items from
  /// the source sequence, batched whenever test passes.
  ///
  /// ### Example
  ///
  ///     Stream.periodic(Duration(milliseconds: 100), (int i) => i)
  ///       .windowTest((i) => i % 2 == 0)
  ///       .asyncMap((stream) => stream.toList())
  ///       .listen(print); // prints [0], [1, 2] [3, 4] [5, 6] ...
  Stream<Stream<T>> windowTest(bool onTestHandler(T event)) =>
      transform(WindowTestStreamTransformer(onTestHandler));

  /// Creates a Stream where each item is a [Stream] containing the items from
  /// the source sequence, sampled on a time frame with [duration].
  ///
  /// ### Example
  ///
  ///     Stream.periodic(Duration(milliseconds: 100), (int i) => i)
  ///       .windowTime(Duration(milliseconds: 220))
  ///       .doOnData((_) => print('next window'))
  ///       .flatMap((s) => s)
  ///       .listen(print); // prints next window 0, 1, next window 2, 3, ...
  Stream<Stream<T>> windowTime(Duration duration) {
    if (duration == null) throw ArgumentError.notNull('duration');

    return window(Stream<void>.periodic(duration));
  }

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the two streams using the provided function.
  ///
  /// If the latestFromStream has not emitted any values, this stream will not
  /// emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2]).withLatestFrom(
  ///       Stream.fromIterable([2, 3]), (a, b) => a + b)
  ///       .listen(print); // prints 4 (due to the async nature of streams)
  Stream<R> withLatestFrom<S, R>(Stream<S> latestFromStream, R fn(T t, S s)) =>
      transform(WithLatestFromStreamTransformer.with1(latestFromStream, fn));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the streams into a list. This is helpful when you need
  /// to combine a dynamic number of Streams.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///     Stream.fromIterable([1, 2]).withLatestFromList(
  ///         [
  ///           Stream.fromIterable([2, 3]),
  ///           Stream.fromIterable([3, 4]),
  ///           Stream.fromIterable([4, 5]),
  ///           Stream.fromIterable([5, 6]),
  ///           Stream.fromIterable([6, 7]),
  ///         ],
  ///       ).listen(print); // print [2, 2, 3, 4, 5, 6] (due to the async nature of streams)
  ///
  Stream<List<T>> withLatestFromList(Iterable<Stream<T>> latestFromStreams) =>
      transform(WithLatestFromStreamTransformer.withList(latestFromStreams));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the three streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom2(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         (int a, int b, int c) => a + b + c,
  ///       )
  ///       .listen(print); // prints 7 (due to the async nature of streams)
  Stream<R> withLatestFrom2<A, B, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    R fn(T t, A a, B b),
  ) =>
      transform(WithLatestFromStreamTransformer.with2(
        latestFromStream1,
        latestFromStream2,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the four streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom3(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         (int a, int b, int c, int d) => a + b + c + d,
  ///       )
  ///       .listen(print); // prints 11 (due to the async nature of streams)
  Stream<R> withLatestFrom3<A, B, C, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    R fn(T t, A a, B b, C c),
  ) =>
      transform(WithLatestFromStreamTransformer.with3(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the five streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom4(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         (int a, int b, int c, int d, int e) => a + b + c + d + e,
  ///       )
  ///       .listen(print); // prints 16 (due to the async nature of streams)
  Stream<R> withLatestFrom4<A, B, C, D, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    R fn(T t, A a, B b, C c, D d),
  ) =>
      transform(WithLatestFromStreamTransformer.with4(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the six streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom5(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         (int a, int b, int c, int d, int e, int f) => a + b + c + d + e + f,
  ///       )
  ///       .listen(print); // prints 22 (due to the async nature of streams)
  Stream<R> withLatestFrom5<A, B, C, D, E, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    R fn(T t, A a, B b, C c, D d, E e),
  ) =>
      transform(WithLatestFromStreamTransformer.with5(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the seven streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom6(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         (int a, int b, int c, int d, int e, int f, int g) =>
  ///             a + b + c + d + e + f + g,
  ///       )
  ///       .listen(print); // prints 29 (due to the async nature of streams)
  Stream<R> withLatestFrom6<A, B, C, D, E, F, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    R fn(T t, A a, B b, C c, D d, E e, F f),
  ) =>
      transform(WithLatestFromStreamTransformer.with6(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the eight streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom7(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         Stream.fromIterable([8, 9]),
  ///         (int a, int b, int c, int d, int e, int f, int g, int h) =>
  ///             a + b + c + d + e + f + g + h,
  ///       )
  ///       .listen(print); // prints 37 (due to the async nature of streams)
  Stream<R> withLatestFrom7<A, B, C, D, E, F, G, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g),
  ) =>
      transform(WithLatestFromStreamTransformer.with7(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the nine streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom8(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         Stream.fromIterable([8, 9]),
  ///         Stream.fromIterable([9, 10]),
  ///         (int a, int b, int c, int d, int e, int f, int g, int h, int i) =>
  ///             a + b + c + d + e + f + g + h + i,
  ///       )
  ///       .listen(print); // prints 46 (due to the async nature of streams)
  Stream<R> withLatestFrom8<A, B, C, D, E, F, G, H, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    Stream<H> latestFromStream8,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g, H h),
  ) =>
      transform(WithLatestFromStreamTransformer.with8(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        latestFromStream8,
        fn,
      ));

  /// Creates a Stream that emits when the source stream emits, combining the
  /// latest values from the ten streams using the provided function.
  ///
  /// If any of latestFromStreams has not emitted any values, this stream will
  /// not emit either.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#withLatestFrom)
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 2])
  ///       .withLatestFrom9(
  ///         Stream.fromIterable([2, 3]),
  ///         Stream.fromIterable([3, 4]),
  ///         Stream.fromIterable([4, 5]),
  ///         Stream.fromIterable([5, 6]),
  ///         Stream.fromIterable([6, 7]),
  ///         Stream.fromIterable([7, 8]),
  ///         Stream.fromIterable([8, 9]),
  ///         Stream.fromIterable([9, 10]),
  ///         Stream.fromIterable([10, 11]),
  ///         (int a, int b, int c, int d, int e, int f, int g, int h, int i, int j) =>
  ///             a + b + c + d + e + f + g + h + i + j,
  ///       )
  ///       .listen(print); // prints 46 (due to the async nature of streams)
  Stream<R> withLatestFrom9<A, B, C, D, E, F, G, H, I, R>(
    Stream<A> latestFromStream1,
    Stream<B> latestFromStream2,
    Stream<C> latestFromStream3,
    Stream<D> latestFromStream4,
    Stream<E> latestFromStream5,
    Stream<F> latestFromStream6,
    Stream<G> latestFromStream7,
    Stream<H> latestFromStream8,
    Stream<I> latestFromStream9,
    R fn(T t, A a, B b, C c, D d, E e, F f, G g, H h, I i),
  ) =>
      transform(WithLatestFromStreamTransformer.with9(
        latestFromStream1,
        latestFromStream2,
        latestFromStream3,
        latestFromStream4,
        latestFromStream5,
        latestFromStream6,
        latestFromStream7,
        latestFromStream8,
        latestFromStream9,
        fn,
      ));

  /// Returns a Stream that combines the current stream together with another
  /// stream using a given zipper function.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1])
  ///         .zipWith(Stream.fromIterable([2]), (one, two) => one + two)
  ///         .listen(print); // prints 3
  Stream<R> zipWith<S, R>(Stream<S> other, R zipper(T t, S s)) =>
      ZipStream.zip2(this, other, zipper);

  /// Convert the current Observable into a [ConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publish();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // Subject
  /// subscription.cancel();
  /// ```
  ConnectableObservable<T> publish() => PublishConnectableObservable<T>(this);

  /// Convert the current Observable into a [ValueConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValue();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the last emitted value
  /// connectable.listen(print); // Prints 3
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject
  /// subscription.cancel();
  /// ```
  ValueConnectableObservable<T> publishValue() =>
      ValueConnectableObservable<T>(this);

  /// Convert the current Observable into a [ValueConnectableObservable]
  /// that can be listened to multiple times, providing an initial seeded value.
  /// It will not begin emitting items from the original Observable
  /// until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays the latest emitted value to any new
  /// listener. It also provides access to the latest value synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishValueSeeded(0);
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 0, 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the last emitted value
  /// connectable.listen(print); // Prints 3
  ///
  /// // Can access the latest emitted value synchronously. Prints 3
  /// print(connectable.value);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject
  /// subscription.cancel();
  /// ```
  ValueConnectableObservable<T> publishValueSeeded(T seedValue) =>
      ValueConnectableObservable<T>.seeded(this, seedValue);

  /// Convert the current Observable into a [ReplayConnectableObservable]
  /// that can be listened to multiple times. It will not begin emitting items
  /// from the original Observable until the `connect` method is invoked.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream that replays a given number of items to any new
  /// listener. It also provides access to the emitted values synchronously.
  ///
  /// ### Example
  ///
  /// ```
  /// final source = Observable.fromIterable([1, 2, 3]);
  /// final connectable = source.publishReplay();
  ///
  /// // Does not print anything at first
  /// connectable.listen(print);
  ///
  /// // Start listening to the source Observable. Will cause the previous
  /// // line to start printing 1, 2, 3
  /// final subscription = connectable.connect();
  ///
  /// // Late subscribers will receive the emitted value, up to a specified
  /// // maxSize
  /// connectable.listen(print); // Prints 1, 2, 3
  ///
  /// // Can access a list of the emitted values synchronously. Prints [1, 2, 3]
  /// print(connectable.values);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject
  /// subscription.cancel();
  /// ```
  ReplayConnectableObservable<T> publishReplay({int maxSize}) =>
      ReplayConnectableObservable<T>(this, maxSize: maxSize);

  /// Convert the current Observable into a new Observable that can be listened
  /// to multiple times. It will automatically begin emitting items when first
  /// listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream
  /// final observable = Observable.fromIterable([1, 2, 3]).share();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // PublishSubject
  /// subscription.cancel();
  /// ```
  Stream<T> share() => publish().refCount();

  /// Convert the current Observable into a new [ValueObservable] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// It will replay the latest emitted value to any new listener.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final observable = Observable.fromIterable([1, 2, 3]).shareValue();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValue() => publishValue().refCount();

  /// Convert the current Observable into a new [ValueObservable] that can
  /// be listened to multiple times, providing an initial value.
  /// It will automatically begin emitting items when first listened to,
  /// and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for providing sync access to the latest
  /// emitted value.
  ///
  /// It will replay the latest emitted value to any new listener.
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final observable = Observable.fromIterable([1, 2, 3]).shareValueSeeded(0);
  ///
  /// // Start listening to the source Observable. Will start printing 0, 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the latest value
  /// print(observable.value);
  ///
  /// // Subscribe again later. This will print 3 because it receives the last
  /// // emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // BehaviorSubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ValueObservable<T> shareValueSeeded(T seedValue) =>
      publishValueSeeded(seedValue).refCount();

  /// Convert the current Observable into a new [ReplayObservable] that can
  /// be listened to multiple times. It will automatically begin emitting items
  /// when first listened to, and shut down when no listeners remain.
  ///
  /// This is useful for converting a single-subscription stream into a
  /// broadcast Stream. It's also useful for gaining access to the l
  ///
  /// It will replay the emitted values to any new listener, up to a given
  /// [maxSize].
  ///
  /// ### Example
  ///
  /// ```
  /// // Convert a single-subscription fromIterable stream into a broadcast
  /// // stream that will emit the latest value to any new listeners
  /// final observable = Observable.fromIterable([1, 2, 3]).shareReplay();
  ///
  /// // Start listening to the source Observable. Will start printing 1, 2, 3
  /// final subscription = observable.listen(print);
  ///
  /// // Synchronously print the emitted values up to a given maxSize
  /// // Prints [1, 2, 3]
  /// print(observable.values);
  ///
  /// // Subscribe again later. This will print 1, 2, 3 because it receives the
  /// // last emitted value.
  /// final subscription2 = observable.listen(print);
  ///
  /// // Stop emitting items from the source stream and close the underlying
  /// // ReplaySubject by cancelling all subscriptions.
  /// subscription.cancel();
  /// subscription2.cancel();
  /// ```
  ReplayObservable<T> shareReplay({int maxSize}) =>
      publishReplay(maxSize: maxSize).refCount();
}
