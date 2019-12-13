import 'dart:async';
import 'dart:collection';

/// Create a [Stream] which implements a [HashSet] under the hood, using
/// the provided `equals` as equality.
///
/// The [Stream] will only emit an event, if that event is not yet found
/// within the underlying [HashSet].
///
/// ###  Example
///
///     Stream.fromIterable([1, 2, 1, 2, 1, 2, 3, 2, 1])
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
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which emits events from the source
  /// [Stream] as if they were processed through a [HashSet].
  ///
  /// See [HashSet] for a more detailed explanation.
  DistinctUniqueStreamTransformer(
      {bool Function(T e1, T e2) equals, int Function(T e) hashCode})
      : _transformer = _buildTransformer(equals, hashCode);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      bool Function(T e1, T e2) equals, int Function(T e) hashCode) {
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

/// Extends the Stream class with the ability to skip items that have previously
/// been emitted.
extension DistinctUniqueExtension<T> on Stream<T> {
  /// WARNING: More commonly known as distinct in other Rx implementations.
  /// Creates a Stream where data events are skipped if they have already
  /// been emitted before.
  ///
  /// Equality is determined by the provided equals and hashCode methods.
  /// If these are omitted, the '==' operator and hashCode on the last provided
  /// data element are used.
  ///
  /// The returned stream is a broadcast stream if this stream is. If a
  /// broadcast stream is listened to more than once, each subscription will
  /// individually perform the equals and hashCode tests.
  ///
  /// [Interactive marble diagram](http://rxmarbles.com/#distinct)
  Stream<T> distinctUnique({
    bool Function(T e1, T e2) equals,
    int Function(T e) hashCode,
  }) =>
      transform(DistinctUniqueStreamTransformer<T>(
          equals: equals, hashCode: hashCode));
}
