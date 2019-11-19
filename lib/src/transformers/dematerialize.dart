import 'dart:async';

import 'package:rxdart/src/utils/notification.dart';

/// Converts the onData, onDone, and onError [Notification] objects from a
/// materialized stream into normal onData, onDone, and onError events.
///
/// When a stream has been materialized, it emits onData, onDone, and onError
/// events as [Notification] objects. Dematerialize simply reverses this by
/// transforming [Notification] objects back to a normal stream of events.
///
/// ### Example
///
///     Stream<Notification<int>>
///         .fromIterable([Notification.onData(1), Notification.onDone()])
///         .transform(dematerializeTransformer())
///         .listen((i) => print(i)); // Prints 1
///
/// ### Error example
///
///     Stream<Notification<int>>
///         .fromIterable([Notification.onError(Exception(), null)])
///         .transform(dematerializeTransformer())
///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
class DematerializeStreamTransformer<T>
    extends StreamTransformerBase<Notification<T>, T> {
  final StreamTransformer<Notification<T>, T> _transformer;

  /// Constructs a [StreamTransformer] which converts the onData, onDone, and
  /// onError [Notification] objects from a materialized stream into normal
  /// onData, onDone, and onError events.
  DematerializeStreamTransformer() : _transformer = _buildTransformer();

  @override
  Stream<T> bind(Stream<Notification<T>> stream) => _transformer.bind(stream);

  static StreamTransformer<Notification<T>, T> _buildTransformer<T>() {
    return StreamTransformer<Notification<T>, T>(
        (Stream<Notification<T>> input, bool cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<Notification<T>> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            subscription = input.listen((Notification<T> notification) {
              try {
                if (notification.isOnData) {
                  controller.add(notification.value);
                } else if (notification.isOnDone) {
                  controller.close();
                } else if (notification.isOnError) {
                  controller.addError(
                      notification.error, notification.stackTrace);
                }
              } catch (e, s) {
                controller.addError(e, s);
              }
            },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) {
            subscription.pause(resumeSignal);
          },
          onResume: () {
            subscription.resume();
          },
          onCancel: () {
            return subscription.cancel();
          });

      return controller.stream.listen(null);
    });
  }
}

/// Converts the onData, onDone, and onError [Notification]s from a
/// materialized stream into normal onData, onDone, and onError events.
extension DematerializeExtension<T> on Stream<Notification<T>> {
  /// Converts the onData, onDone, and onError [Notification] objects from a
  /// materialized stream into normal onData, onDone, and onError events.
  ///
  /// When a stream has been materialized, it emits onData, onDone, and onError
  /// events as [Notification] objects. Dematerialize simply reverses this by
  /// transforming [Notification] objects back to a normal stream of events.
  ///
  /// ### Example
  ///
  ///     Stream<Notification<int>>
  ///         .fromIterable([Notification.onData(1), Notification.onDone()])
  ///         .dematerialize()
  ///         .listen((i) => print(i)); // Prints 1
  ///
  /// ### Error example
  ///
  ///     Stream<Notification<int>>
  ///         .fromIterable([Notification.onError(Exception(), null)])
  ///         .dematerialize()
  ///         .listen(null, onError: (e, s) { print(e) }); // Prints Exception
  Stream<T> dematerialize() {
    return transform(DematerializeStreamTransformer<T>());
  }
}
