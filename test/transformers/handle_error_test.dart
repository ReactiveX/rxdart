import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.handleError', () async {
    final expected = new ArgumentError();

    final obs = new Observable(new ErrorStream<void>(new Exception()))
        .handleError((dynamic _) {
      throw expected;
    });

    obs.listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
      expect(obs is Observable, isTrue);
    }));
  });
}
