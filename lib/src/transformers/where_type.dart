import 'dart:async';

/// This transformer is a shorthand for [Stream.where] followed by [Stream.cast].
///
/// Events that do not match [T] are filtered out, the resulting
/// [Stream] will be of Type [T].
///
/// ### Example
///
///     Observable.fromIterable([1, 'two', 3, 'four'])
///       .whereType<int>()
///       .listen(print); // prints 1, 3
///
/// // as opposed to:
///
///     Observable.fromIterable([1, 'two', 3, 'four'])
///       .where((event) => event is int)
///       .cast<int>()
///       .listen(print); // prints 1, 3
///
class WhereTypeStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> transformer;

  WhereTypeStreamTransformer() : transformer = _buildTransformer();

  @override
  Stream<T> bind(Stream<S> stream) => transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>() =>
      StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
        StreamController<T> controller;
        StreamSubscription<S> subscription;

        controller = StreamController<T>(
            sync: true,
            onListen: () {
              subscription = input.listen((event) {
                if (event == null) return;

                T eventCast;

                try {
                  eventCast = event as T;
                } on CastError catch (_) {
                  return;
                } catch (e, s) {
                  return controller.addError(e, s);
                }

                controller.add(eventCast);
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
