import 'dart:async';

/// This transformer is a shorthand for [Stream.where] followed by [Stream.cast].
///
/// Events that do not match [T] are filtered out, the resulting
/// [Stream] will be of Type [T].
///
/// ### Example
///
///     Stream.fromIterable([1, 'two', 3, 'four'])
///       .whereType<int>()
///       .listen(print); // prints 1, 3
///
/// // as opposed to:
///
///     Stream.fromIterable([1, 'two', 3, 'four'])
///       .where((event) => event is int)
///       .cast<int>()
///       .listen(print); // prints 1, 3
///
class WhereTypeStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> _transformer;

  /// Constructs a [StreamTransformer] which combines [Stream.where] followed by [Stream.cast].
  WhereTypeStreamTransformer() : _transformer = _buildTransformer();

  @override
  Stream<T> bind(Stream<S> stream) => _transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>() =>
      StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<S> subscription;

        controller = StreamController<T>(
            sync: true,
            onListen: () {
              subscription = input.listen((event) {
                try {
                  if (event is T) {
                    controller.add(event);
                  }
                } catch (e, s) {
                  controller.addError(e, s);
                }
              },
                  onError: controller.addError,
                  onDone: controller.close,
                  cancelOnError: cancelOnError);
            },
            onPause: ([Future<dynamic> resumeSignal]) =>
                subscription.pause(resumeSignal),
            onResume: () => subscription.resume(),
            onCancel: () => subscription.cancel());

        return controller.stream.listen(null);
      });
}

/// Extends the Stream class with the ability to filter down events to only
/// those of a specific type.
extension WhereTypeExtension<T> on Stream<T> {
  /// This transformer is a shorthand for [Stream.where] followed by
  /// [Stream.cast].
  ///
  /// Events that do not match [T] are filtered out, the resulting [Stream] will
  /// be of Type [T].
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable([1, 'two', 3, 'four'])
  ///       .whereType<int>()
  ///       .listen(print); // prints 1, 3
  ///
  /// #### as opposed to:
  ///
  ///     Stream.fromIterable([1, 'two', 3, 'four'])
  ///       .where((event) => event is int)
  ///       .cast<int>()
  ///       .listen(print); // prints 1, 3
  Stream<S> whereType<S>() => transform(WhereTypeStreamTransformer<T, S>());
}
