import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

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

      await expectLater(
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

      await expectLater(
          observable,
          emitsInOrder(<dynamic>[
            new _TestObject("a"),
            new _TestObject("b"),
            new _TestObject("c"),
            emitsDone
          ]));
    });

    test(
        "sends an error to the subscription if an error occurs in the equals or hashmap methods",
        () async {
      Stream<_TestObject> observable =
          new Observable<_TestObject>.fromIterable(<_TestObject>[
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c")
      ]).distinctUnique(
              equals: (_TestObject a, _TestObject b) => a.key == b.key,
              hashCode: (_TestObject o) =>
                  throw new Exception('Catch me if you can!'));

      observable.listen(
        null,
        onError: expectAsync2(
          (Exception e, StackTrace s) => expect(e, isException),
          count: 3,
        ),
      );
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

      await expectLater(
          firstStream,
          emitsInOrder(<dynamic>[
            new _TestObject("a"),
            new _TestObject("b"),
            new _TestObject("c"),
            emitsDone
          ]));

      await expectLater(
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
