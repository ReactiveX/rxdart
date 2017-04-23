import 'dart:async';
import 'dart:collection';

///
class DistinctUniqueStreamTransformer<T> implements StreamTransformer<T, T> {
  final StreamTransformer<T, T> transformer;
  DistinctUniqueStreamTransformer(bool equals(T e1, T e2), int hashCode(T e))
      : transformer = _buildTransformer(equals, hashCode);

  @override
  Stream<T> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(
      bool equals(T e1, T e2), int hashCode(T e)) {
    return new StreamTransformer<T, T>((Stream<T> input, bool cancelOnError) {
      HashSet<T> collection =
          new HashSet<T>(equals: equals, hashCode: hashCode);
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              if (collection.add(value)) controller.add(value);
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
