import 'dart:async';

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, in batches of count.
///
/// If skip is provided, each group will start where the previous group
/// ended minus the skip value.
///
/// ### Example
///
///     new Stream.fromIterable([1, 2, 3, 4])
///       .transform(new BufferWithCountStreamTransformer(2))
///       .listen(print); // prints [1, 2], [3, 4]
///
/// ### Example with skip
///
///     new Stream.fromIterable([1, 2, 3, 4])
///       .transform(new BufferWithCountStreamTransformer(2, 1))
///       .listen(print); // prints [1, 2], [2, 3], [3, 4], [4]
class BufferWithCountStreamTransformer<T, S extends List<T>>
    extends StreamTransformerBase<T, S> {
  final int count;
  final int skip;

  BufferWithCountStreamTransformer(this.count, [this.skip]);

  @override
  Stream<S> bind(Stream<T> stream) =>
      _buildTransformer<T, S>(count, skip).bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S extends List<T>>(
      int count,
      [int skip]) {
    assertCountAndSkip(count, skip);

    final int bufferKeep = count - ((skip == null) ? count : skip);
    List<T> buffer = <T>[];

    return new StreamTransformer<T, S>.fromHandlers(
        handleData: (T data, EventSink<S> sink) {
      buffer.add(data);

      if (buffer.length == count) {
        sink.add(buffer);

        buffer = buffer.sublist(count - bufferKeep);
      }
    }, handleDone: (EventSink<S> sink) {
      if (buffer.isNotEmpty) sink.add(buffer);
    });
  }

  static void assertCountAndSkip(int count, [int skip]) {
    final int skipAmount = skip == null ? count : skip;

    if (count == null) {
      throw new ArgumentError('count cannot be null');
    } else if (skipAmount <= 0 || skipAmount > count) {
      throw new ArgumentError(
          'skip has to be greater than zero and smaller than count');
    }
  }
}
