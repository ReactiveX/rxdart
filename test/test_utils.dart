library test.utils;

import 'dart:async';
import 'package:rxdart/rxdart.dart' as Rx;

Future<List> testObservable(Rx.Observable observable) {
  final Completer<List> C = new Completer();
  final List results = [];

  observable.subscribe(
      (value) => results.add(value),
      onError: (error) => print(error),
      onCompleted: () => C.complete(results)
  );

  return C.future;
}