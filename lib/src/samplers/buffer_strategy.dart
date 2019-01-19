import 'dart:async';

import 'package:rxdart/src/samplers/utils.dart';
import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/take_until.dart';

/// Higher order function signature which matches the method signature
/// of buffer and window.
typedef Stream<S> SamplerBuilder<T, S>(Stream<T> stream,
    OnDataTransform<T, S> bufferHandler, OnDataTransform<S, S> scheduleHandler);

/// Higher order function implementation for [_OnCountSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, in batches of [count].
///
/// If [startBufferEvery] is provided, each group will start where the previous group
/// ended minus the [startBufferEvery] value.
Stream<S> Function(
  Stream<T> stream,
  OnDataTransform<T, S>,
  OnDataTransform<S, S>,
) onCount<T, S>(int count, [int startBufferEvery = 0]) => (
      Stream<T> stream,
      OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler,
    ) {
      return new _OnCountSampler<T, S>(
        stream,
        bufferHandler,
        scheduleHandler,
        count,
        startBufferEvery,
      );
    };

/// Higher order function implementation for [_OnStreamSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, sampled on [onStream].
Stream<S> Function(
  Stream<T> stream,
  OnDataTransform<T, S>,
  OnDataTransform<S, S>,
) onStream<T, S, O>(Stream<O> onStream) {
  return (
    Stream<T> stream,
    OnDataTransform<T, S> bufferHandler,
    OnDataTransform<S, S> scheduleHandler,
  ) {
    return new _OnStreamSampler<T, S, O>(
      stream,
      bufferHandler,
      scheduleHandler,
      onStream,
    );
  };
}

/// Higher order function implementation for [_OnStreamSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, sampled on a time frame with [duration].
Stream<S> Function(
  Stream<T> stream,
  OnDataTransform<T, S>,
  OnDataTransform<S, S>,
) onTime<T, S>(Duration duration) {
  return (
    Stream<T> stream,
    OnDataTransform<T, S> bufferHandler,
    OnDataTransform<S, S> scheduleHandler,
  ) {
    if (duration == null) {
      throw new ArgumentError('duration cannot be null');
    }

    return new _OnStreamSampler<T, S, Null>(
      stream,
      bufferHandler,
      scheduleHandler,
      new Stream<Null>.periodic(duration),
    );
  };
}

/// Higher order function implementation for [_OnStreamSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, batched whenever [onFuture] completes.
Stream<S> Function(
  Stream<T> stream,
  OnDataTransform<T, S>,
  OnDataTransform<S, S>,
) onFuture<T, S, O>(Future<O> onFuture()) {
  return (
    Stream<T> stream,
    OnDataTransform<T, S> bufferHandler,
    OnDataTransform<S, S> scheduleHandler,
  ) {
    if (onFuture == null) {
      throw new ArgumentError('onFuture cannot be null');
    }

    return new _OnStreamSampler<T, S, O>(
      stream,
      bufferHandler,
      scheduleHandler,
      _onFutureSampler(onFuture),
    );
  };
}

/// transforms [onFuture] into a sampler [Stream] by recursively awaiting
/// the next [Future]
Stream<O> _onFutureSampler<O>(Future<O> onFuture()) async* {
  yield await onFuture();
  yield* _onFutureSampler(onFuture);
}

/// Higher order function implementation for [_OnTestSampler]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, batched whenever [onTest] passes.
Stream<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTest<T, S>(bool onTest(T event)) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnTestSampler<T, S>(
            stream, bufferHandler, scheduleHandler, onTest);

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, sampled on [onStream].
class _OnStreamSampler<T, S, O> extends StreamView<S> {
  @override
  _OnStreamSampler._(Stream<S> state) : super(state);

  factory _OnStreamSampler(
      Stream<T> stream,
      OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler,
      Stream<O> onStream) {
    final doneController = new StreamController<bool>();
    if (onStream == null) {
      throw new ArgumentError('onStream cannot be null');
    }

    final ticker = onStream.transform<dynamic>(
        new TakeUntilStreamTransformer<Null, dynamic>(doneController.stream));

    void onDone() {
      if (doneController.isClosed) return;

      doneController.add(true);
      doneController.close();
    }

    final scheduler = stream
        .transform(new DoStreamTransformer<T>(onDone: onDone, onCancel: onDone))
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (T data, EventSink<S> sink) {
              bufferHandler(data, sink, 0);
            },
            handleError: (Object error, StackTrace s, EventSink<S> sink) =>
                sink.addError(error, s)))
        .transform(
            new SampleStreamTransformer<S>(ticker, sampleOnValueOnly: false))
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (S data, EventSink<S> sink) {
              scheduleHandler(data, sink, 0);
            },
            handleError: (Object error, StackTrace s, EventSink<S> sink) =>
                sink.addError(error, s)));

    return new _OnStreamSampler<T, S, O>._(scheduler);
  }
}

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, in batches of the specified count.
///
/// If [skip] is provided, each group will start where the previous group
/// ended minus the [skip] value.
class _OnCountSampler<T, S> extends StreamView<S> {
  @override
  _OnCountSampler._(Stream<S> state) : super(state);

  factory _OnCountSampler(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, int count,
      [int startBufferEvery = 0]) {
    var eventIndex = 0;

    if (count == null) {
      throw new ArgumentError('count cannot be null');
    } else if (count < 1) {
      throw new ArgumentError(
          'count needs to be greater than 1, currently it is: $count');
    }

    if (startBufferEvery < 0) {
      throw new ArgumentError(
          'startBufferEvery needs to be greater than, or equal to 0, currently it is: $startBufferEvery');
    }

    bool maybeNewBuffer(S _) => eventIndex % count == 0;

    final scheduler = stream
        .transform<S>(new StreamTransformer<T, S>.fromHandlers(
            handleData: (T data, EventSink<S> sink) {
              if (++eventIndex > 0) bufferHandler(data, sink, startBufferEvery);
            },
            handleError: (Object error, StackTrace s, EventSink<S> sink) =>
                sink.addError(error, s)))
        .where(maybeNewBuffer)
        .transform<S>(new StreamTransformer<S, S>.fromHandlers(
            handleData: (S data, EventSink<S> sink) {
              eventIndex -= startBufferEvery;
              scheduleHandler(data, sink, startBufferEvery);
            },
            handleError: (Object error, StackTrace s, EventSink<S> sink) =>
                sink.addError(error, s)));

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
    var testResult = false;

    if (onTest == null) {
      throw new ArgumentError('onTest cannot be null');
    }

    final scheduler = stream
        .transform<S>(new StreamTransformer<T, S>.fromHandlers(
            handleData: (T data, EventSink<S> sink) {
              testResult = onTest(data);
              bufferHandler(data, sink, 0);
            },
            handleError: (Object error, StackTrace s, EventSink<S> sink) =>
                sink.addError(error, s)))
        .where((_) => testResult)
        .transform<S>(new StreamTransformer<S, S>.fromHandlers(
            handleData: (S data, EventSink<S> sink) {
              scheduleHandler(data, sink, 0);
            },
            handleError: (Object error, StackTrace s, EventSink<S> sink) =>
                sink.addError(error, s)));

    return new _OnTestSampler<T, S>._(scheduler);
  }
}
