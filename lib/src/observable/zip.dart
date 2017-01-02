library rx.observable.zip;

import 'dart:async';

import 'package:rxdart/src/observable/stream.dart';

class ZipObservable<T> extends StreamObservable<T> with ControllerMixin<T> {

  StreamController<T> _controller;

  ZipObservable(Iterable<Stream<dynamic>> streams, Function predicate, bool asBroadcastStream) {
    final List<bool> pausedStates = new List<bool>.generate(streams.length, (_) => false, growable: false);
    final List<StreamSubscription<dynamic>> subscriptions = new List<StreamSubscription<dynamic>>(streams.length);

    _controller = new StreamController<T>(sync: true,
      onListen: () {
        final List<dynamic> values = new List<dynamic>(streams.length);
        final List<bool> completedStatus = new List<bool>.generate(streams.length, (_) => false);

        void doUpdate(int index, dynamic value) {
          values[index] = value;
          pausedStates[index] = true;

          // subscriptions[i] might be null if doUpdate triggers instantly (i.e. BehaviourSubject)
          if (subscriptions[index] != null) subscriptions[index].pause();

          if (_areAllPaused(pausedStates)) {
            updateWithValues(predicate, values);

            _resumeAll(subscriptions, pausedStates);
          }
        }

        void markDone(int i) {
          completedStatus[i] = true;

          if (completedStatus.reduce((bool a, bool b) => a && b)) _controller.close();
        }

        for (int i=0, len=streams.length; i<len; i++) {
          subscriptions[i] = streams.elementAt(i).listen((dynamic value) => doUpdate(i, value),
            onError: _controller.addError,
            onDone: () => markDone(i));

          // updating the above subscription if doUpdate triggered too soon
          if (pausedStates[i] && !subscriptions[i].isPaused) subscriptions[i].pause();
        }
      },
      onCancel: () => Future.wait(subscriptions
        .map((StreamSubscription<dynamic> subscription) => subscription.cancel())
        .where((Future<dynamic> cancelFuture) => cancelFuture != null))
    );

    setStream(asBroadcastStream ? _controller.stream.asBroadcastStream() : _controller.stream);
  }

  void updateWithValues(Function predicate, Iterable<dynamic> values) {
    try {
      dynamic result = Function.apply(predicate, values);

      if (result is T) _controller.add(result);
      else if (result == null) _controller.add(null);
      else _controller.addError(new ArgumentError('predicate result is of type ${result.runtimeType} and not of expected type $T'));
    } catch (e, s) {
      _controller.addError(e, s);
    }
  }

  bool _areAllPaused(List<bool> pausedStates) {
    for (int i=0, len=pausedStates.length; i<len; i++) {
      if (!pausedStates[i]) return false;
    }

    return true;
  }

  void _resumeAll(List<StreamSubscription<dynamic>> subscriptions, List<bool> pausedStates) {
    for (int i=0, len=subscriptions.length; i<len; i++) {
      pausedStates[i] = false;
      subscriptions[i].resume();
    }
  }

}