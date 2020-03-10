import 'dart:async';

class _OnErrorResumeStreamSink<S> implements EventSink<S> {
  final Stream<S> Function(Object error) _recoveryFn;
  final EventSink<S> _outputSink;
  var _inRecovery = false;

  _OnErrorResumeStreamSink(this._outputSink, this._recoveryFn);

  @override
  void add(S data) {
    if (!_inRecovery) {
      _outputSink.add(data);
    }
  }

  @override
  void addError(e, [st]) {
    _inRecovery = true;

    final recoveryStream = _recoveryFn(e);

    recoveryStream.listen(_outputSink.add,
        onError: _outputSink.addError, onDone: _outputSink.close);
  }

  @override
  void close() {
    if (!_inRecovery) {
      _outputSink.close();
    }
  }
}

/// Intercepts error events and switches to a recovery stream created by the
/// provided recoveryFn Function.
///
/// The OnErrorResumeStreamTransformer intercepts an onError notification from
/// the source Stream. Instead of passing the error through to any
/// listeners, it replaces it with another Stream of items created by the
/// recoveryFn.
///
/// The recoveryFn receives the emitted error and returns a Stream. You can
/// perform logic in the recoveryFn to return different Streams based on the
/// type of error that was emitted.
///
/// ### Example
///
///     Stream<int>.error(Exception())
///       .onErrorResume((dynamic e) =>
///           Stream.value(e is StateError ? 1 : 0)
///       .listen(print); // prints 0
class OnErrorResumeStreamTransformer<S> extends StreamTransformerBase<S, S> {
  /// Method which returns a [Stream], based from the error.
  final Stream<S> Function(Object error) recoveryFn;

  /// Constructs a [StreamTransformer] which intercepts error events and
  /// switches to a recovery [Stream] created by the provided [recoveryFn] Function.
  OnErrorResumeStreamTransformer(this.recoveryFn);

  @override
  Stream<S> bind(Stream<S> stream) => Stream.eventTransformed(
      stream, (sink) => _OnErrorResumeStreamSink<S>(sink, recoveryFn));
}

/// Extends the Stream class with the ability to recover from errors in various
/// ways
extension OnErrorExtensions<T> on Stream<T> {
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
  ///     ErrorStream(Exception())
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
  ///     ErrorStream(Exception())
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
  ///     ErrorStream(Exception())
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
  ///     ErrorStream(Exception())
  ///       .onErrorReturnWith((e) => e is Exception ? 1 : 0)
  ///       .listen(print); // prints 1
  Stream<T> onErrorReturnWith(T Function(dynamic error) returnFn) =>
      transform(OnErrorResumeStreamTransformer<T>(
          (dynamic e) => Stream<T>.fromIterable([returnFn(e)])));
}
