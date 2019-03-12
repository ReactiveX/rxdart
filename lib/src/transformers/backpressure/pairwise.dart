import 'package:rxdart/src/streams/never.dart';
import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// Emits the n-th and n-1th events as a pair..
///
/// ### Example
///
///     Observable.range(1, 4)
///       .pairwise()
///       .listen(print); // prints [1, 2], [2, 3], [3, 4]
class PairwiseStreamTransformer<T>
    extends BackpressureStreamTransformer<T, Iterable<T>> {
  PairwiseStreamTransformer()
      : super(WindowStrategy.firstEventOnly, (_) => NeverStream<void>(),
            onWindowEnd: (Iterable<T> queue) => queue,
            startBufferEvery: 1,
            closeWindowWhen: (Iterable<T> queue) => queue.length == 2,
            dispatchOnClose: false);
}
