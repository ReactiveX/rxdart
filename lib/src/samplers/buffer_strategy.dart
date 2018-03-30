import 'dart:async';

import 'package:rxdart/src/samplers/utils.dart';

import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/take_until.dart';

/// Higher order function signature which matches the method signature
/// of buffer and window.
typedef SamplerBloc<S> BufferBlocBuilder<T, S>(Stream<T> stream,
    OnDataTransform<T, S> bufferHandler, OnDataTransform<S, S> scheduleHandler);

/// Higher order function implementation for [_OnCountBloc]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, in batches of [count].
///
/// If [skip] is provided, each group will start where the previous group
/// ended minus the [skip] value.
SamplerBloc<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onCount<T, S>(int count, [int skip]) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnCountBloc<T, S>(
            stream, bufferHandler, scheduleHandler, count, skip);

/// Higher order function implementation for [_OnStreamBloc]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, sampled on [onStream].
SamplerBloc<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onStream<T, S>(Stream<dynamic> onStream) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnStreamBloc<T, S>(
            stream, bufferHandler, scheduleHandler, onStream);

/// Higher order function implementation for [_OnStreamBloc]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, sampled on a time frame with [duration].
SamplerBloc<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTime<T, S>(Duration duration) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnStreamBloc<T, S>(stream, bufferHandler, scheduleHandler,
            new Stream<Null>.periodic(duration));

/// Higher order function implementation for [_OnFutureBloc]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, batched whenever [onFuture] completes.
SamplerBloc<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onFuture<T, S>(Future<dynamic> onFuture()) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnStreamBloc<T, S>(
            stream, bufferHandler, scheduleHandler, _onFutureSampler(onFuture));

Stream<dynamic> _onFutureSampler(Future<dynamic> onFuture()) async* {
  while (true) yield await onFuture();
}

/// Higher order function implementation for [_OnTestBloc]
/// which matches the method signature of buffer and window.
///
/// Each item is a sequence containing the items
/// from the source sequence, batched whenever [onTest] passes.
SamplerBloc<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTest<T, S>(bool onTest(T event)) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnTestBloc<T, S>(stream, bufferHandler, scheduleHandler, onTest);

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, sampled on [onStream].
class _OnStreamBloc<T, S> implements SamplerBloc<S> {
  @override
  final Stream<S> state;

  _OnStreamBloc._(this.state);

  factory _OnStreamBloc(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, Stream<dynamic> onStream) {
    final doneController = new StreamController<bool>();
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
        .transform(new SampleStreamTransformer(ticker))
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              scheduleHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnStreamBloc._(scheduler);
  }
}

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, in batches of [count].
///
/// If [skip] is provided, each group will start where the previous group
/// ended minus the [skip] value.
class _OnCountBloc<T, S> implements SamplerBloc<S> {
  @override
  final Stream<S> state;

  _OnCountBloc._(this.state);

  factory _OnCountBloc(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, int count,
      [int skip]) {
    var eventIndex = 0;

    final scheduler = stream
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (data, sink) {
              skip ??= 0;

              if (count == null) {
                sink.addError(new ArgumentError('count cannot be null'));
                sink.close();
              } else if (skip > count) {
                sink.addError(
                    new ArgumentError('skip cannot be greater than count'));
                sink.close();
              } else {
                eventIndex++;
                bufferHandler(data, sink, skip);
              }
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

    return new _OnCountBloc<T, S>._(scheduler);
  }
}

/// A buffer strategy where each item is a sequence containing the items
/// from the source sequence, batched whenever [onTest] passes.
class _OnTestBloc<T, S> implements SamplerBloc<S> {
  @override
  final Stream<S> state;

  _OnTestBloc._(this.state);

  factory _OnTestBloc(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, bool onTest(T event)) {
    bool testResult = false;

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

    return new _OnTestBloc<T, S>._(scheduler);
  }
}
