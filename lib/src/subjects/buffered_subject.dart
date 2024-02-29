import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

abstract class _BufferEntry<T> {
  void addToSink(StreamSink<T> controller);
}

class _BufferedEvent<T> extends _BufferEntry<T> {
  final T value;
  _BufferedEvent(this.value);

  @override
  void addToSink(StreamSink<T> controller) => controller.add(value);
}

class _BufferedError<T> extends _BufferEntry<T> {
  final Object error;
  final StackTrace? stackTrace;
  _BufferedError(this.error, this.stackTrace);

  @override
  void addToSink(StreamSink<T> controller) => controller.addError(error, stackTrace);
}

/// A special StreamController that captures all of the items that are
/// added to the controller if it has no listener, and emits those as the
/// first items to the first new listener.
///
/// This subject allows sending data, error and done events to the listener.
/// As items are added to the subject, the BufferedSubject will store them.
/// When the stream is listened to, those recorded items will be emitted to
/// the listener. After that, any new events will be appropriately sent to the
/// listeners. It is possible to cap the number of stored events by setting
/// a maxSize value.
///
/// BufferedSubject is, by default, a broadcast (aka hot) controller, in order
/// to fulfill the Rx Subject contract. This means the Subject's `stream` can
/// be listened to multiple times.
///
/// ### Example
///
///     final subject = BufferedSubject<int>();
///
///     subject.add(1);
///     subject.add(2);
///     subject.add(3);
///
///     final completer = Completer<void>();
///     final StreamSubscription subscription = subject.stream.listen((event) {
///       print(event);
///       if (event == 3) {
///         completer.complete();
///       }
///     }); // prints 1, 2, 3
///
///     await completer.future;
///     await subscription.cancel();
///
///     subject.add(4);
///     subject.stream.listen(print); // prints 4
///
/// ### Example with maxSize
///
///     final subject = BufferedSubject<int>(maxSize: 2);
///
///     subject.add(1);
///     subject.add(2);
///     subject.add(3);
///
///     final completer = Completer<void>();
///     final StreamSubscription subscription = subject.stream.listen((event) {
///       print(event);
///       if (event == 3) {
///         completer.complete();
///       }
///     }); // prints 2, 3
///
///     await completer.future;
///     await subscription.cancel();
///
///     subject.add(4);
///     subject.stream.listen(print); // prints 4
class BufferedSubject<T> extends Subject<T> {
  bool _isAddingStreamItems = false;
  final int? _maxSize;
  final Queue<_BufferEntry> _buffer;
  final StreamController<T> _controller;
  @override
  void Function()? onListen;

  BufferedSubject._(this._controller, Stream<T> stream, this._maxSize, this._buffer, this.onListen)
      : super(_controller, stream) {
    _controller.onListen = () {
      for (final el in _buffer) {
        el.addToSink(_controller);
      }
      _buffer.clear();
      onListen?.call();
    };
  }

  /// Constructs a [BufferedSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// See also [StreamController.broadcast]
  factory BufferedSubject({void Function()? onListen, void Function()? onCancel, bool sync = false, int? maxSize}) {
    final Queue<_BufferEntry<T>> buffer = Queue();
    final controller = StreamController<T>.broadcast(onCancel: onCancel, sync: sync);

    return BufferedSubject<T>._(controller, controller.stream, maxSize, buffer, onListen);
  }

  @override
  void add(T event) {
    if (hasListener) {
      super.add(event);
    } else {
      _verifyState();
      _buffer.add(_BufferedEvent<T>(event));
      _truncateBuffer();
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (hasListener) {
      super.addError(error, stackTrace);
    } else {
      _verifyState();
      _buffer.add(_BufferedError<T>(error, stackTrace));
      _truncateBuffer();
    }
  }

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) async {
    if (hasListener) {
      return super.addStream(source, cancelOnError: cancelOnError);
    } else {
      _verifyState();
      final completer = Completer<void>();
      _isAddingStreamItems = true;

      source.listen(
        (T event) {
          _buffer.add(_BufferedEvent<T>(event));
          _truncateBuffer();
        },
        cancelOnError: cancelOnError,
        onDone: completer.complete,
        onError: (Object e, StackTrace s) {
          _buffer.add(_BufferedError<T>(e, s));
          _truncateBuffer();
          if (cancelOnError == true) completer.complete();
        },
      );

      return completer.future.then((_) {
        _isAddingStreamItems = false;
      });
    }
  }

  void _truncateBuffer() {
    final max = _maxSize;
    while (max != null && _buffer.length > max) {
      _buffer.removeFirst();
    }
  }

  void _verifyState() {
    if (_isAddingStreamItems) {
      throw StateError('You cannot add items while items are being added from addStream');
    }
  }

  @override
  Future<dynamic> close() async {
    if (!hasListener) _verifyState();
    return super.close();
  }
}
