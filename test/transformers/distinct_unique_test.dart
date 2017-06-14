import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  group("DistinctUniqueStreamTransformer", () {
    test("rx.Observable.distinctUnique.withoutEqualsAndHash", () async {
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

    test("rx.Observable.distinctUnique.withEqualsAndHash", () async {
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

    test("rx.Observable.distinctUnique.error.shouldThrow", () async {
      Stream<_TestObject> observable =
          new Observable<_TestObject>.fromIterable(<_TestObject>[
        new _TestObject("a"),
        new _TestObject("b"),
        new _TestObject("c")
      ]).distinctUnique(
              equals: (_TestObject a, _TestObject b) => a.key == b.key,
              hashCode: (_TestObject o) =>
                  throw new Exception('Catch me if you can!'));

      observable.listen(null,
          onError: expectAsync2((e, s) => expect(e, isException), count: 3));
    });

    test("rx.Observable.distinctUnique.isReusable", () async {
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
