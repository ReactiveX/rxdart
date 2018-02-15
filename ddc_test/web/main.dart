import 'package:rxdart/rxdart.dart';

// Side note: To maintain readability, this example was not formatted using dart_fmt.

void main() {
  new Observable.fromIterable(const <int>[1, 2, 3, 4, 5])
      .map((int value) => '+$value')
      .flatMapLatest((String value) => new Observable<String>.just(value))
      .flatMap((String value) => new Observable<String>.just(value))
      .bufferWithCount(2, 1)
      .doOnData((_) => print('blah'))
      .interval(const Duration(milliseconds: 20))
      .debounce(const Duration(milliseconds: 20))
      .listen((_) => print(_));
}