import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

/// See buffer_xxx_test.dart files for specific buffer scenarios
/// using [onCount], [onFuture], [onTest], [onTime], [onStream]
void main() {
  test('rx.Observable.buffer.onNull.shouldThrow', () {
    Observable<int>.fromIterable(<int>[1, 2, 3, 4]).buffer(null).listen(null,
        onError: expectAsync2((NoSuchMethodError e, StackTrace s) {
      expect(e, isNoSuchMethodError);
    }));
  });
}
