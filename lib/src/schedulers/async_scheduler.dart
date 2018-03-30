import 'dart:async';

import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/take_until.dart';

import 'package:rxdart/src/streams/error.dart';

typedef StreamSampler<S> StreamSamplerType<T, S>(Stream<T> stream,
    OnDataTransform<T, S> bufferHandler, OnDataTransform<S, S> scheduleHandler);

typedef void OnDataTransform<T, S>(T event, EventSink<S> sink, [int skip]);

abstract class StreamSampler<T> {
  Stream<T> get onSample;
}

StreamSampler<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onCount<T, S>(int count, [int skip]) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnCountImpl<T, S>(
            stream, bufferHandler, scheduleHandler, count, skip);

StreamSampler<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onStream<T, S>(Stream<dynamic> onStream) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnStreamImpl<T, S>(
            stream, bufferHandler, scheduleHandler, onStream);

StreamSampler<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTime<T, S>(Duration duration) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) {
          Stream<Null> ticker;

          if (stream.isBroadcast) {
            ticker = new Stream<Null>.periodic(duration).asBroadcastStream();
          } else {
            ticker = new Stream<Null>.periodic(duration);
          }

          return new _OnStreamImpl<T, S>(
              stream, bufferHandler, scheduleHandler, ticker);
        };

StreamSampler<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onFuture<T, S>(Future<dynamic> onFuture()) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnFutureImpl<T, S>(
            stream, bufferHandler, scheduleHandler, onFuture);

StreamSampler<S> Function(
        Stream<T> stream, OnDataTransform<T, S>, OnDataTransform<S, S>)
    onTest<T, S>(bool onTest(T event)) => (Stream<T> stream,
            OnDataTransform<T, S> bufferHandler,
            OnDataTransform<S, S> scheduleHandler) =>
        new _OnTestImpl<T, S>(stream, bufferHandler, scheduleHandler, onTest);

class _OnStreamImpl<T, S> implements StreamSampler<S> {
  @override
  final Stream<S> onSample;

  _OnStreamImpl._(this.onSample);

  factory _OnStreamImpl(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, Stream<dynamic> onStream) {
    final doneController = new StreamController<bool>();

    var onDone = () {
      if (doneController.isClosed) return;

      doneController.add(true);
      doneController.close();
    };
    final Stream<dynamic> ticker = onStream
        .transform<Null>(new TakeUntilStreamTransformer(doneController.stream));

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

    return new _OnStreamImpl._(scheduler);
  }
}

class _OnFutureImpl<T, S> implements StreamSampler<S> {
  @override
  final Stream<S> onSample;

  _OnFutureImpl._(this.onSample);

  factory _OnFutureImpl(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
      OnDataTransform<S, S> scheduleHandler, Future<dynamic> onFuture()) {
    Future<S> Function(S) onFutureHandler() =>
        (S data) => onFuture().then((dynamic _) => data);

    final scheduler = stream
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (data, sink) {
              bufferHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)))
        .asyncMap(onFutureHandler())
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              scheduleHandler(data, sink, 0);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnFutureImpl._(scheduler);
  }
}

class _OnCountImpl<T, S> implements StreamSampler<S> {
  @override
  final Stream<S> onSample;

  _OnCountImpl._(this.onSample);

  factory _OnCountImpl(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
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
        .where((S data) => eventIndex % count == 0)
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              skip ??= 0;
              eventIndex -= skip;
              scheduleHandler(data, sink, skip);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnCountImpl<T, S>._(scheduler);
  }
}

class _OnTestImpl<T, S> implements StreamSampler<S> {
  @override
  final Stream<S> onSample;

  _OnTestImpl._(this.onSample);

  factory _OnTestImpl(Stream<T> stream, OnDataTransform<T, S> bufferHandler,
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

    return new _OnTestImpl<T, S>._(scheduler);
  }
}
