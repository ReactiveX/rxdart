import 'dart:async';
import 'dart:collection';

/// Create an `Observable` which implements a [HashSet] under the hood, using
/// the provided `equals` as equality.
///
/// The `Observable` will only emit an event, if that event is not yet found
/// within the underlying [HashSet].
///
/// ###  Example
///
///     new Stream.fromIterable([1, 2, 1, 2, 1, 2, 3, 2, 1])
///         .listen((event) => print(event));
///
/// will emit:
///     1, 2, 3
///
/// The provided `equals` must define a stable equivalence relation, and
/// `hashCode` must be consistent with `equals`.
///
/// If `equals` or `hashCode` are omitted, the set uses the elements' intrinsic
/// `Object.==` and `Object.hashCode`. If you supply one of `equals` and
/// `hashCode`, you should generally also to supply the other.
class DistinctUniqueStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> transformer;

  DistinctUniqueStreamTransformer({bool equals(T e1, T e2), int hashCode(T e)})
      : transformer = _buildTransformer(equals, hashCode);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      bool equals(T e1, T e2), int hashCode(T e)) {
    return StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      var collection = HashSet<T>(equals: equals, hashCode: hashCode);
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              try {
                if (collection.add(value)) controller.add(value);
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
          onCancel: () {
            collection.clear();
            collection = null;
            return subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}
