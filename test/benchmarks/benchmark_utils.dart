import 'package:rxdart/rxdart.dart';

Observable<int> range() =>
    new Observable<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
