import 'dart:async';

/// Deprecated: Please use OnErrorResumeStreamTransformer.
///
/// Intercepts error events and switches to the given recovery stream in
/// that case
///
/// The OnErrorResumeNextStreamTransformer intercepts an onError notification from
/// the source Stream. Instead of passing the error through to any
/// listeners, it replaces it with another Stream of items.
///
/// ### Example
///
///     new ErrorStream(new Exception())
///       .transform(new OnErrorResumeNextStreamTransformer(
///         new Observable.fromIterable([1, 2, 3])))
///       .listen(print); // prints 1, 2, 3
@deprecated
class OnErrorResumeNextStreamTransformer<T>
    extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  OnErrorResumeNextStreamTransformer(Stream<T> recoveryStream)
      : transformer = _buildTransformer(recoveryStream);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      Stream<T> recoveryStream) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      StreamSubscription<T> inputSubscription;
      StreamSubscription<T> recoverySubscription;
      StreamController<T> controller;
      var shouldCloseController = true;

      void safeClose() {
        if (shouldCloseController) {
          controller.close();
        }
      }

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            inputSubscription =
                input.listen(controller.add, onError: (dynamic e, dynamic s) {
              shouldCloseController = false;

              recoverySubscription = recoveryStream.listen(controller.add,
                  onError: controller.addError,
                  onDone: controller.close,
                  cancelOnError: cancelOnError);

              inputSubscription.cancel();
            }, onDone: safeClose, cancelOnError: cancelOnError);
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
