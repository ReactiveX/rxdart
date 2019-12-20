import 'dart:async';

/// Emits values emitted by the source Stream so long as each value
/// satisfies the given test. When the test is not satisfied by a value, it
/// will emit this value as a final event and then complete.
///
/// ### Example
///
///     Stream.fromIterable([2, 3, 4, 5, 6, 1, 2, 3])
///       .transform(TakeWhileInclusiveStreamTransformer((i) => i < 4))
///       .listen(print); // prints 2, 3, 4
class TakeWhileInclusiveStreamTransformer<T>
    extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which forwards data events while [test]
  /// is successful, and includes last event that caused [test] to return false.
  TakeWhileInclusiveStreamTransformer(bool Function(T) test)
      : _transformer = _buildTransformer(test);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(bool Function(T) test) {
    if (test == null) {
      throw ArgumentError.notNull('test');
    }

    return StreamTransformer<T, T>((input, cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      void onDone() {
        if (!controller.isClosed) {
          controller.close();
        }
      }

      controller = StreamController<T>(
        sync: true,
        onListen: () {
          bool satisfies;

          subscription = input.listen(
            (data) {
              try {
                satisfies = test(data);
              } catch (e, s) {
                controller.addError(e, s);
                // The test didn't say true. Didn't say false either, but we stop anyway.
                controller.close();
                return;
              }

              if (satisfies) {
                controller.add(data);
              } else {
                controller.add(data);
                controller.close();
              }
            },
            onError: controller.addError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );
        },
        onPause: ([Future<dynamic> resumeSignal]) =>
            subscription.pause(resumeSignal),
        onResume: () => subscription.resume(),
        onCancel: () => subscription.cancel(),
      );

      return controller.stream.listen(null);
    });
  }
}

/// Extends the Stream class with the ability to take events while they pass
/// the condition given and include last event that doesn't pass the condition.
extension TakeWhileInclusiveExtension<T> on Stream<T> {
  /// Emits values emitted by the source Stream so long as each value
  /// satisfies the given test. When the test is not satisfied by a value, it
  /// will emit this value as a final event and then complete.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([2, 3, 4, 5, 6, 1, 2, 3])
  ///       .takeWhileInclusive((i) => i < 4)
  ///       .listen(print); // prints 2, 3, 4
  Stream<T> takeWhileInclusive(bool Function(T) test) =>
      transform(TakeWhileInclusiveStreamTransformer(test));
}
