import 'dart:async';

import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/src/subjects/replay_subject.dart';

abstract class ReplayObservable<T> implements Observable<T> {
  List<T> get values;
}

class StreamReplayObservable<T> extends Observable<T>
    implements ReplayObservable<T> {
  final ReplaySubject<T> _subject;

  factory StreamReplayObservable(Stream<T> stream, {int maxSize}) {
    ReplaySubject<T> subject;
    StreamSubscription<T> subscription;

    subject = new ReplaySubject<T>(
        sync: true,
        maxSize: maxSize,
        onListen: () {
          subscription = stream.listen(
            subject.add,
            onError: subject.addError,
            onDone: subject.close,
          );
        },
        onCancel: () {
          subject.close();
          subscription.cancel();
        });

    return StreamReplayObservable<T>._(subject);
  }

  StreamReplayObservable._(this._subject) : super(_subject);

  @override
  List<T> get values => _subject.values;
}
