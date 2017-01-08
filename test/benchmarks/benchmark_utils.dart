import 'dart:async';

import 'package:rxdart/rxdart.dart' as rx;

rx.Observable<int> range() => new rx.Observable<int>.fromIterable(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);