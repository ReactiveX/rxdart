import 'dart:async';

import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';

abstract class ValueObservable<T> implements Observable<T> {
  T get value;
}

class SubjectValueObservable<T> extends Observable<T>
    implements ValueObservable<T> {
  final BehaviorSubject<T> _subject;

  factory SubjectValueObservable(Stream<T> stream, {T seedValue}) {
    BehaviorSubject<T> subject;
    StreamSubscription<T> subscription;

    subject = new BehaviorSubject<T>(
      sync: true,
      seedValue: seedValue,
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
      },
    );

    return SubjectValueObservable<T>._(subject);
  }

  SubjectValueObservable._(this._subject) : super(_subject);

  @override
  T get value => _subject.value;
}
