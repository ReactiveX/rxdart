import 'dart:async';

import 'package:rxdart/src/transformers/do.dart';
import 'package:rxdart/src/transformers/sample.dart';
import 'package:rxdart/src/transformers/take_until.dart';

import 'package:rxdart/src/streams/error.dart';

typedef StreamScheduler<T> StreamSchedulerType<T>(Stream<T> stream);

abstract class StreamScheduler<T> {
  Stream<List<T>> get onSchedule;
}

StreamScheduler<T> Function(Stream<T> stream) onCount<T>(int count) =>
    (Stream<T> stream) => new _OnCountImpl<T>(stream, count);

StreamScheduler<T> Function(Stream<T> stream) onTime<T>(Duration duration) =>
    (Stream<T> stream) => new _OnTimeImpl<T>(stream, duration);

class _OnTimeImpl<T> implements StreamScheduler<T> {
  @override
  final Stream<List<T>> onSchedule;

  _OnTimeImpl._(this.onSchedule);

  factory _OnTimeImpl(Stream<T> stream, Duration duration) {
    final doneController = new StreamController<bool>();
    var buffer = <T>[];
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
        .transform(new StreamTransformer<T, List<T>>.fromHandlers(
            handleData: (data, sink) {
              buffer.add(data);
              sink.add(buffer);
            },
            handleError: (error, s, sink) => sink.addError(error, s)))
        .transform(new SampleStreamTransformer(ticker))
        .transform(new StreamTransformer<List<T>, List<T>>.fromHandlers(
            handleData: (data, sink) {
              sink.add(new List<T>.unmodifiable(data));
              data.clear();
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnTimeImpl._(scheduler);
  }
}

class _OnCountImpl<T> implements StreamScheduler<T> {
  @override
  final Stream<List<T>> onSchedule;

  _OnCountImpl._(this.onSchedule);

  factory _OnCountImpl(Stream<T> stream, int count) {
    var buffer = <T>[];
    var eventIndex = 0;

    final scheduler =
        stream.transform(new StreamTransformer<T, List<T>>.fromHandlers(
            handleData: (data, sink) {
              buffer.add(data);

              if (++eventIndex % count == 0) {
                sink.add(new List<T>.unmodifiable(buffer));

                buffer.clear();
              }
            },
            handleError: (error, s, sink) => sink.addError(error, s)));

    return new _OnCountImpl<T>._(scheduler);
  }
}
