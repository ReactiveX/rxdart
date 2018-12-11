import 'dart:async';

import 'package:rxdart/src/observables/observable.dart';

/// Transforms a Stream so that will only emit items from the source sequence
/// if a particular time span has passed without the source sequence emitting
/// another item.
///
/// The Debounce Transformer filters out items emitted by the source Observable
/// that are rapidly followed by another emitted item.
///
/// [Interactive marble diagram](http://rxmarbles.com/#debounce)
///
/// ### Example
///
///     new Observable.fromIterable([1, 2, 3, 4])
///       .debounce(new Duration(seconds: 1))
///       .listen(print); // prints 4
class RepeatStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final StreamTransformer<S, T> transformer;

  RepeatStreamTransformer(int count,
      {Observable<T> sequenceFactory(Observable<S> stream)})
      : transformer = _buildTransformer(count, sequenceFactory);

  @override
  Stream<T> bind(Stream<S> stream) => transformer.bind(stream);

  static StreamTransformer<S, T> _buildTransformer<S, T>(
      int count, Observable<T> sequenceFactory(Observable<S> stream)) {
    return new StreamTransformer<S, T>((Stream<S> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<S> subscription;
      StreamSubscription<T> outputSubscription;
      var currentCount = 0;

      controller = new StreamController<T>(
          sync: true,
          onListen: () {
            sequenceFactory ??= (Observable<S> stream) => stream.cast<T>();

            Stream<T> buildSequence(S value) {
              if (sequenceFactory != null) {
                return sequenceFactory(Observable.just(value));
              }

              return Observable.just(value as T);
            }

            void repeatNextSequence(S withValue) {
              outputSubscription = buildSequence(withValue)
                  .listen(controller.add, onError: controller.addError,
                      onDone: () {
                outputSubscription?.cancel();

                if (++currentCount == count) {
                  subscription.resume();
                } else {
                  repeatNextSequence(withValue);
                }
              });
            }

            subscription = input.listen((S value) {
              try {
                subscription.pause();
                currentCount = 0;

                repeatNextSequence(value);
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
          onCancel: () async {
            if (outputSubscription != null) await outputSubscription.cancel();

            return await subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}
