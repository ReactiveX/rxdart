import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

/// See window_xxx_test.dart files for specific window scenarios
/// using [onCount], [onFuture], [onTest], [onTime], [onStream]
void main() {
  test('rx.Observable.window.onNull.shouldThrow', () {
    Observable<int>.fromIterable(<int>[1, 2, 3, 4]).window(null).listen(null,
        onError: expectAsync2((NoSuchMethodError e, StackTrace s) {
      expect(e, isNoSuchMethodError);
    }));
  });
}
