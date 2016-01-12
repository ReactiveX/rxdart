library rx.observable.combine_latest_map;

import 'package:rxdart/src/observable/stream.dart';

class CombineLatestObservableMap<T extends Map<String, dynamic>> extends StreamObservable<T> with ControllerMixin<T> {

  CombineLatestObservableMap(Map<String, Stream> streamMap, bool asBroadcastStream) {
    final List<StreamSubscription> subscriptions = new List<StreamSubscription>(streamMap.length);

    controller = new StreamController<T>(sync: true,
        onListen: () {
          final Map<Stream, dynamic> values = <Stream, dynamic>{};
          final Map<Stream, bool> triggered = <Stream, bool>{};
          final Map<Stream, bool> completedStatus = <Stream, bool>{};

          void doUpdate(Stream stream, dynamic value) {
            values[stream] = value;
            triggered[stream] = true;

            if (triggered.values.reduce((bool a, bool b) => a && b)) {
              final T result = <String, dynamic>{} as T;

              streamMap.forEach((String key, Stream stream) => result[key] = values[stream]);

              controller.add(result);
            }
          }

          void markDone(Stream stream) {
            completedStatus[stream] = true;

            if (completedStatus.values.reduce((bool a, bool b) => a && b)) controller.close();
          }

          for (int i=0, len=streamMap.length; i<len; i++) {
            Stream stream = streamMap.values.elementAt(i);

            subscriptions[i] = stream.listen((dynamic value) => doUpdate(stream, value),
              onError: (e, s) => throwError(e, s),
              onDone: () => markDone(stream));

            triggered[stream] = false;
            completedStatus[stream] = false;
          }
        },
        onCancel: () => Future.wait(subscriptions
          .map((StreamSubscription subscription) => subscription.cancel())
          .where((Future cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? controller.stream.asBroadcastStream() : controller.stream);
  }

}