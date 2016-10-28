library rx.operators.pluck;

import 'package:rxdart/src/observable/stream.dart';

class PluckObservable<T, S> extends StreamObservable<S> {

  PluckObservable(Stream<T> stream, List<dynamic> sequence, {bool throwOnNull: false}) {
    setStream(stream.transform(new StreamTransformer<T, S>.fromHandlers(
      handleData: (T data, EventSink<S> sink) {
        dynamic curVal = data;

        sequence.forEach((dynamic part) {
          try {
            curVal = curVal[part];
          } catch (error) {
            sink.addError(error, error.stackTrace);
          }
        });

        if (throwOnNull && curVal == null) {
          final PluckError error = new PluckError();

          sink.addError(error, error.stackTrace);
        } else {
          try {
            dynamic result = curVal;

            if (result is S) sink.add(result);
            else if (result == null) sink.add(null);
            else sink.addError(new ArgumentError('predicate result is of type ${result.runtimeType} and not of expected type $S'));
          } catch (error) {
            sink.addError(error, error.stackTrace);
          }
        }
      }
    )));
  }

}

class PluckError extends Error {

  final String message;

  PluckError() : message = 'Value was resolved as null from the pluck sequence';

  @override String toString() => message;

}