import 'dart:async';

/// The GroupBy operator divides a [Stream] that emits items into
/// a [Stream] that emits [GroupByStream],
/// each one of which emits some subset of the items
/// from the original source [Stream].
///
/// [GroupByStream] acts like a regular [Stream], yet
/// adding a 'key' property, which receives its [Type] and value from
/// the [_grouper] Function.
///
/// All items with the same key are emitted by the same [GroupByStream].

class GroupByStreamTransformer<T, S>
    extends StreamTransformerBase<T, GroupByStream<T, S>> {
  final StreamTransformer<T, GroupByStream<T, S>> _transformer;

  /// Constructs a [StreamTransformer] which groups events from the source
  /// [Stream] and emits them as [GroupByStream].
  GroupByStreamTransformer(S Function(T event) grouper)
      : _transformer = _buildTransformer<T, S>(grouper);

  @override
  Stream<GroupByStream<T, S>> bind(Stream<T> stream) =>
      _transformer.bind(stream);

  static StreamTransformer<T, GroupByStream<T, S>> _buildTransformer<T, S>(
      S Function(T event) grouper) {
    return StreamTransformer<T, GroupByStream<T, S>>(
        (Stream<T> input, bool cancelOnError) {
      final mapper = <S, StreamController<T>>{};
      StreamController<GroupByStream<T, S>> controller;
      StreamSubscription<T> subscription;

      final controllerBuilder = (S forKey) => () {
            final groupedController = StreamController<T>();

            controller
                .add(GroupByStream<T, S>(forKey, groupedController.stream));

            return groupedController;
          };

      controller = StreamController<GroupByStream<T, S>>(
          sync: true,
          onListen: () {
            subscription = input.listen(
                (T value) {
                  try {
                    final key = grouper(value);
                    // ignore: close_sinks
                    final groupedController =
                        mapper.putIfAbsent(key, controllerBuilder(key));

                    groupedController.add(value);
                  } catch (e, s) {
                    controller.addError(e, s);
                  }
                },
                onError: controller.addError,
                onDone: () {
                  mapper.values.forEach((controller) => controller.close());
                  mapper.clear();

                  controller.close();
                });
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}

/// The [Stream] used by [GroupByStreamTransformer], it contains events
/// that are grouped by a key value.
class GroupByStream<T, S> extends StreamView<T> {
  /// The key is the category to which all events in this group belong to.
  final S key;

  /// Constructs a [Stream] which only emits events that can be
  /// categorized under [key].
  GroupByStream(this.key, Stream<T> stream) : super(stream);
}

/// Extends the Stream class with the ability to convert events into Streams
/// of events that are united by a key.
extension GroupByExtension<T> on Stream<T> {
  /// The GroupBy operator divides a [Stream] that emits items into a [Stream]
  /// that emits [GroupByStream], each one of which emits some subset of the
  /// items from the original source [Stream].
  ///
  /// [GroupByStream] acts like a regular [Stream], yet adding a 'key' property,
  /// which receives its [Type] and value from the [grouper] Function.
  ///
  /// All items with the same key are emitted by the same [GroupByStream].
  Stream<GroupByStream<T, S>> groupBy<S>(S Function(T value) grouper) =>
      transform(GroupByStreamTransformer<T, S>(grouper));
}
