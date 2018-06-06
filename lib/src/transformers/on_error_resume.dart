import 'dart:async';

/// Intercepts error events and switches to a recovery stream created by the
/// provided recoveryFn function.
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
///     new Observable<int>.error(new Exception())
///       .onErrorResume((dynamic e) =>
///           new Observable.just(e is StateError ? 1 : 0)
///       .listen(print); // prints 0
class OnErrorResumeStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  OnErrorResumeStreamTransformer(Stream<T> Function(dynamic error) recoveryFn)
      : transformer = _buildTransformer(recoveryFn);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
    Stream<T> Function(dynamic error) recoveryFn,
  ) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamSubscription<T> inputSubscription;
      StreamSubscription<T> recoverySubscription;
      StreamController<T> controller;
      bool shouldCloseController = true;

      void safeClose() {
        if (shouldCloseController) {
          controller.close();
        }
      }

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            inputSubscription = input.listen(
              controller.add,
              onError: (dynamic e, dynamic s) {
                shouldCloseController = false;

                recoverySubscription = recoveryFn(e).listen(
                  controller.add,
                  onError: controller.addError,
                  onDone: controller.close,
                  cancelOnError: cancelOnError,
                );

                inputSubscription.cancel();
              },
              onDone: safeClose,
              cancelOnError: cancelOnError,
            );
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            inputSubscription?.pause(resumeSignal);
            recoverySubscription?.pause(resumeSignal);
          },
          onResume: () {
            inputSubscription?.resume();
            recoverySubscription?.resume();
          },
          onCancel: () {
            return Future.wait<dynamic>(<Future<dynamic>>[
              inputSubscription?.cancel(),
              recoverySubscription?.cancel()
            ].where((Future<dynamic> future) => future != null));
          });

      return controller.stream.listen(null);
    });
  }
}
