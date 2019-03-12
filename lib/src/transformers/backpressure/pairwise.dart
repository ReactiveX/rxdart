import 'package:rxdart/src/streams/never.dart';
import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

/// Triggers on the second and subsequent triggerings of the input observable.
/// The Nth triggering of the input observable passes the arguments from the N-1th and Nth triggering as a pair.
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
