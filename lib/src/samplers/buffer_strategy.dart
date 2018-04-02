import 'dart:async';

import 'package:rxdart/src/samplers/utils.dart';

import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/take_until.dart';

/// Higher order function signature which matches the method signature
/// of buffer and window.
typedef StreamView<S> SamplerBuilder<T, S>(Stream<T> stream,
    OnDataTransform<T, S> bufferHandler, OnDataTransform<S, S> scheduleHandler);

/// Higher order function implementation for [_OnCountSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, in batches of [count].
///
/// If [skip] is provided, each group will start where the previous group
/// ended minus the [skip] value.
StreamView<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onCount<T, S>(int count, [int skip]) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnCountSampler<T, S>(
            stream, bufferHandler, scheduleHandler, count, skip);

/// Higher order function implementation for [_OnStreamSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, sampled on [onStream].
StreamView<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onStream<T, S>(Stream<dynamic> onStream) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnStreamSampler<T, S>(
            stream, bufferHandler, scheduleHandler, onStream);

/// Higher order function implementation for [_OnStreamSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, sampled on a time frame with [duration].
StreamView<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTime<T, S>(Duration duration) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) {
          if (duration == null) {
            throw new ArgumentError('duration cannot be null');
          }

          return new _OnStreamSampler<T, S>(stream, bufferHandler,
              scheduleHandler, new Stream<Null>.periodic(duration));
        };

/// Higher order function implementation for [_OnStreamSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, batched whenever [onFuture] completes.
StreamView<S> Function(Stream<T> stream, OnDataTransform<T, S>,
    OnDataTransform<S, S>) onFuture<T, S>(
        Future<dynamic> onFuture()) =>
    (Stream<T> stream, OnDataTransform<T, S> bufferHandler,
        OnDataTransform<S, S> scheduleHandler) {
      if (onFuture == null) {
        throw new ArgumentError('onFuture cannot be null');
      }

      return new _OnStreamSampler<T, S>(
          stream, bufferHandler, scheduleHandler, _onFutureSampler(onFuture));
    };

/// transforms [onFuture] into a sampler [Stream] by recursively awaiting
/// the next [Future]
Stream<dynamic> _onFutureSampler(Future<dynamic> onFuture()) async* {
  yield await onFuture();
  yield* _onFutureSampler(onFuture);
}

/// Higher order function implementation for [_OnTestSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, batched whenever [onTest] passes.
StreamView<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTest<T, S>(bool onTest(T event)) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnTestSampler<T, S>(
            stream, bufferHandler, scheduleHandler, onTest);

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, sampled on [onStream].
class _OnStreamSampler<T, S> extends StreamView<S> {
  @override
  _OnStreamSampler._(Stream<S> state) : super(state);

  factory _OnStreamSampler(
      Stream<T> stream,
      OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler,
      Stream<dynamic> onStream) {
    final doneController = new StreamController<bool>();
    if (onStream == null) {
      throw new ArgumentError('onStream cannot be null');
    }

    final Stream<dynamic> ticker = onStream
        .transform<Null>(new TakeUntilStreamTransformer(doneController.stream));

    var onDone = () {
      if (doneController.isClosed) return;

      doneController.add(true);
      doneController.close();
    };

    final scheduler = stream
        .transform(new DoStreamTransformer(onDone: onDone, onCancel: onDone))
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (data, sink) {
              bufferHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)))
        .transform(
            new SampleStreamTransformer(ticker, sampleOnValueOnly: false))
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              scheduleHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnStreamSampler._(scheduler);
  }
}

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, in batches of [count].
///
/// If [skip] is provided, each group will start where the previous group
/// ended minus the [skip] value.
class _OnCountSampler<T, S> extends StreamView<S> {
  @override
  _OnCountSampler._(Stream<S> state) : super(state);

  factory _OnCountSampler(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, int count,
      [int skip]) {
    var eventIndex = 0;

    skip ??= 0;

    if (count == null) {
      throw new ArgumentError('count cannot be null');
    } else if (skip > count) {
      throw new ArgumentError('skip cannot be greater than count');
    }

    final scheduler = stream
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (data, sink) {
              eventIndex++;
              bufferHandler(data, sink, skip);
            },
            handleError: (error, s, sink) => sink.addError(error, s)))
        .where((_) => eventIndex % count == 0)
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              skip ??= 0;
              eventIndex -= skip;
              scheduleHandler(data, sink, skip);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnCountSampler<T, S>._(scheduler);
  }
}

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, batched whenever [onTest] passes.
class _OnTestSampler<T, S> extends StreamView<S> {
  @override
  _OnTestSampler._(Stream<S> state) : super(state);

  factory _OnTestSampler(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, bool onTest(T event)) {
    bool testResult = false;

    if (onTest == null) {
      throw new ArgumentError('onTest cannot be null');
    }

    final scheduler = stream
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (data, sink) {
              testResult = onTest(data);
              bufferHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)))
        .where((_) => testResult)
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              scheduleHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnTestSampler<T, S>._(scheduler);
  }
}
