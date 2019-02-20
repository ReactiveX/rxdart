import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.transform', () async {
    final observable = Observable.fromIterable(const [1, 2])
        .transform(TestStreamTransformer());

    observable.listen(expectAsync1((val) {
      expect(val, "Hi");
    }, count: 2));
  });
}

class TestStreamTransformer extends StreamTransformerBase<int, String> {
  @override
  Stream<String> bind(Stream<int> stream) {
    final controller = StreamController<String>();

    stream.listen((_) => controller.add("Hi"), onDone: controller.close);

    return controller.stream;
  }
}
