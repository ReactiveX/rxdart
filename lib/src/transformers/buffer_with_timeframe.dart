import 'dart:async';

import 'package:rxdart/src/observable.dart';

/// Creates an Observable where each item is a list containing the items
/// from the source sequence, sampled on a time frame.
///
/// ### Example
///
///     new Observable.periodic(const Duration(milliseconds: 100), (int i) => i)
///       .bufferWithTimeframe(const Duration(milliseconds: 220))
///       .listen(print); // prints [0, 1] [2, 3] [4, 5] ...
class BufferWithTimeframeStreamTransformer<T>
    extends StreamTransformerBase<T, List<T>> {
  final Duration timeframe;

  BufferWithTimeframeStreamTransformer(this.timeframe);

  @override
  Stream<List<T>> bind(Stream<T> stream) =>
      _buildTransformer<T>(timeframe).bind(stream);

  static StreamTransformer<T, List<T>> _buildTransformer<T>(Duration duration) {
    assertTimeframe(duration);

    return new StreamTransformer<T, List<T>>(
        (Stream<T> input, bool cancelOnError) {
      StreamController<List<T>> controller;
      StreamSubscription<List<T>> subscription;
      List<T> buffer;

      controller = new StreamController<List<T>>(
          sync: true,
          onListen: () {
            /// needed to close the periodic [Stream] in sample
            /// otherwise, this [Stream] would never close
            /// and the onDone event would never trigger
            final doneController = new StreamController<bool>();
            buffer = <T>[];

            List<T> addToBuffer(T event) => buffer..add(event);

            subscription = new Observable(input)
                .doOnDone(() {
                  doneController.add(true);
                  doneController.close();
                })
                .map(addToBuffer)
                .sample(new Observable<Null>.periodic(duration)
                    .takeUntil(doneController.stream))
                .listen(
                    (buffer) {
                      controller.add(new List<T>.unmodifiable(buffer));
                      buffer.clear();
                    },
                    onError: controller.addError,
                    onDone: () {
                      if (buffer.isNotEmpty) {
                        scheduleMicrotask(() {
                          controller.add(buffer);
                          controller.close();
                        });
                      } else {
                        controller.close();
                      }
                    },
                    cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }

  static void assertTimeframe(Duration timeframe) {
    if (timeframe == null) {
      throw new ArgumentError('count cannot be null');
    }
  }
}
