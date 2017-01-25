import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('rx.Observable.transform', () async {
    final Stream<String> observable =
        new Observable<int>.fromIterable(<int>[1, 2])
            .transform(new TestStreamTransformer());

    observable.listen(expectAsync1((String val) {
      expect(val, "Hi");
    }, count: 2));
  });
}

class TestStreamTransformer implements StreamTransformer<int, String> {
  @override
  Stream<String> bind(Stream<int> stream) {
    final StreamController<String> controller = new StreamController<String>();

    stream.listen((int value) => controller.add("Hi"),
        onDone: controller.close);

    return controller.stream;
  }
}
