import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.handleError', () async {
    final expected = ArgumentError();

    final obs =
        Observable(ErrorStream<void>(Exception())).handleError((dynamic _) {
      throw expected;
    });

    obs.listen(null, onError: expectAsync2((ArgumentError e, StackTrace s) {
      expect(e, isArgumentError);
    }));
  });
}
