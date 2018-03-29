import 'dart:async';

import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/take_until.dart';

import 'package:rxdart/src/streams/error.dart';

typedef StreamScheduler<S> StreamSchedulerType<T, S>(
    Stream<T> stream,
    StreamBufferHandler<T, S> bufferHandler,
    StreamBufferHandler<S, S> scheduleHandler);

typedef void StreamBufferHandler<T, S>(T event, EventSink<S> sink, [int skip]);

abstract class StreamScheduler<T> {
  Stream<T> get onSchedule;
}

StreamScheduler<S> Function(
        Stream<T> stream, StreamBufferHandler<T, S>, StreamBufferHandler<S, S>)
    onCount<T, S>(int count, [int skip]) => (Stream<T> stream,
            StreamBufferHandler<T, S> bufferHandler,
            StreamBufferHandler<S, S> scheduleHandler) =>
        new _OnCountImpl<T, S>(
            stream, bufferHandler, scheduleHandler, count, skip);

StreamScheduler<S> Function(
        Stream<T> stream, StreamBufferHandler<T, S>, StreamBufferHandler<S, S>)
    onTime<T, S>(Duration duration, [int skip]) => (Stream<T> stream,
            StreamBufferHandler<T, S> bufferHandler,
            StreamBufferHandler<S, S> scheduleHandler) =>
        new _OnTimeImpl<T, S>(
            stream, bufferHandler, scheduleHandler, duration, skip);

class _OnTimeImpl<T, S> implements StreamScheduler<S> {
  @override
  final Stream<S> onSchedule;

  _OnTimeImpl._(this.onSchedule);

  factory _OnTimeImpl(Stream<T> stream, StreamBufferHandler<T, S> bufferHandler,
      StreamBufferHandler<S, S> scheduleHandler, Duration duration,
      [int skip]) {
    final doneController = new StreamController<bool>();

    var onDone = () {
      doneController.add(true);
      doneController.close();
    };
    Stream<dynamic> ticker;

    if (duration == null) {
      onDone();

      ticker = new ErrorStream<ArgumentError>(
          new ArgumentError('timeframe cannot be null'));
    } else {
      ticker = new Stream<Null>.periodic(duration).transform<Null>(
          new TakeUntilStreamTransformer(doneController.stream));
    }

    final scheduler = stream
        .transform(
            new StreamTransformer<T, T>.fromHandlers(handleData: (data, sink) {
          if (duration == null) {
            onDone();
          } else {
            sink.add(data);
          }
        }))
        .transform(new DoStreamTransformer(onDone: onDone))
        .transform(new StreamTransformer<T, S>.fromHandlers(
            handleData: (data, sink) {
              bufferHandler(data, sink, skip);
            },
            handleError: (error, s, sink) => sink.addError(error, s)))
        .transform(new SampleStreamTransformer(ticker))
        .transform(new StreamTransformer<S, S>.fromHandlers(
            handleData: (data, sink) {
              scheduleHandler(data, sink, skip);
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnTimeImpl._(scheduler);
  }
}

class _OnCountImpl<T, S> implements StreamScheduler<S> {
  @override
  final Stream<S> onSchedule;

  _OnCountImpl._(this.onSchedule);

  factory _OnCountImpl(
      Stream<T> stream,
      StreamBufferHandler<T, S> bufferHandler,
      StreamBufferHandler<S, S> scheduleHandler,
      int count,
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
