import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

Stream<Map<String, Map<int, Map<bool, String>>>> _getStream() =>
    new Stream<Map<String, Map<int, Map<bool, String>>>>.fromIterable(<
        Map<String, Map<int, Map<bool, String>>>>[
      <String, Map<int, Map<bool, String>>>{
        'first': <int, Map<bool, String>>{
          2: <bool, String>{true: 'done!'}
        }
      }
    ]);

void main() {
  test('rx.Observable.pluck', () async {
    observable(_getStream()).pluck(<dynamic>['first', 2, true]).listen(
        (String result) => expect(result, 'done!'));
  });

  test('rx.Observable.pluck.asBroadcastStream', () async {
    Stream<dynamic> stream = observable(_getStream().asBroadcastStream())
        .pluck(<dynamic>['first', 2, true]);

    // listen twice on same stream
    stream.listen((_) {});
    stream.listen((_) {});
    // code should reach here
    expect(true, true);
  });

  test('rx.Observable.pluck.error.shouldThrow.A', () async {
    observable(_getStream()).pluck(<dynamic>['first', 3, true]).listen(null,
        onError: (dynamic e) {
      expect(true, true);
    });
  });

  test('rx.Observable.pluck.error.shouldThrow.B', () async {
    observable(_getStream()).pluck(<dynamic>['first', 2, false],
        throwOnNull: true).listen(null, onError: (dynamic e) {
      expect(true, true);
    });
  });
}
