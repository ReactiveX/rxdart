import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  group("DistinctUniqueStreamTransformer", () {
    test("works with the equals and hascode of the class", () async {
      Stream<_TestObject> observable =
          new Observable<_TestObject>.fromIterable(<_TestObject>[
        new _TestObject("a"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c"),
        new _TestObject("a")
      ]).distinctUnique();

      await expect(
          observable,
          emitsInOrder(<dynamic>[
            new _TestObject("a"),
            new _TestObject("b"),
            new _TestObject("c"),
            emitsDone
          ]));
    });

    test("works with a provided equals and hashcode", () async {
      Stream<_TestObject> observable =
          new Observable<_TestObject>.fromIterable(<_TestObject>[
        new _TestObject("a"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c"),
        new _TestObject("a")
      ]).distinctUnique(
              equals: (_TestObject a, _TestObject b) => a.key == b.key,
              hashCode: (_TestObject o) => o.key.hashCode);

      await expect(
          observable,
          emitsInOrder(<dynamic>[
            new _TestObject("a"),
            new _TestObject("b"),
            new _TestObject("c"),
            emitsDone
          ]));
    });

    test("is reusable", () async {
      final List<_TestObject> data = <_TestObject>[
        new _TestObject("a"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("a"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("b"),
        new _TestObject("c"),
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c"),
        new _TestObject("a")
      ];

      final DistinctUniqueStreamTransformer<_TestObject>
          distinctUniqueStreamTransformer =
          new DistinctUniqueStreamTransformer<_TestObject>();

      Stream<_TestObject> firstStream =
          new Stream<_TestObject>.fromIterable(data)
              .transform(distinctUniqueStreamTransformer);

      Stream<_TestObject> secondStream =
          new Stream<_TestObject>.fromIterable(data)
              .transform(distinctUniqueStreamTransformer);

      await expect(
          firstStream,
          emitsInOrder(<dynamic>[
            new _TestObject("a"),
            new _TestObject("b"),
            new _TestObject("c"),
            emitsDone
          ]));

      await expect(
          secondStream,
          emitsInOrder(<dynamic>[
            new _TestObject("a"),
            new _TestObject("b"),
            new _TestObject("c"),
            emitsDone
          ]));
    });
  });
}

class _TestObject {
  final String key;

  const _TestObject(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestObject &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}
