import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.empty', () async {
    var onDataCalled = false, onErrorCalled = false;

    final observable = Observable<int>.empty();

    observable.listen(
        expectAsync1((_) {
          onDataCalled = true;
        }, count: 0),
        onError: expectAsync2((Exception e, StackTrace s) {
          onErrorCalled = false;
        }, count: 0), onDone: expectAsync0(() {
      // We do not expect onData or onError to be called, as empty streams
      // emit no items nor errors
      expect(onDataCalled, isFalse);
      expect(onErrorCalled, isFalse);
    }));
  });
}
