import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  // expected to match using hashcode, since we use const, all items with the
  // same key have the same hashcode
  test('rx.Observable.distinctUnique', () async {
    final List<_TestObject> expected = <_TestObject>[
      const _TestObject('a'),
      const _TestObject('b'),
      const _TestObject('c')
    ];
    int next = 0;

    Stream<_TestObject> observable =
        new Observable<_TestObject>.fromIterable(<_TestObject>[
      const _TestObject('a'),
      const _TestObject('a'),
      const _TestObject('b'),
      const _TestObject('a'),
      const _TestObject('a'),
      const _TestObject('b'),
      const _TestObject('b'),
      const _TestObject('c'),
      const _TestObject('a'),
      const _TestObject('b'),
      const _TestObject('c'),
      const _TestObject('a')
    ]).distinctUnique();

    observable.listen(expectAsync1((_TestObject actual) {
      expect(actual, expected[next++]);
    }, count: 3));
  });

  // expected to match using an equals method
  test('rx.Observable.distinctUnique.usingEquals', () async {
    final List<_TestObject> expected = <_TestObject>[
      const _TestObject('a'),
      const _TestObject('b'),
      const _TestObject('c')
    ];
    int next = 0;

    bool equals(_TestObject a, _TestObject b) => a.key == b.key;

    Stream<_TestObject> observable =
        new Observable<_TestObject>.fromIterable(<_TestObject>[
      new _TestObject('a'),
      new _TestObject('a'),
      new _TestObject('b'),
      new _TestObject('a'),
      new _TestObject('a'),
      new _TestObject('b'),
      new _TestObject('b'),
      new _TestObject('c'),
      new _TestObject('a'),
      new _TestObject('b'),
      new _TestObject('c'),
      new _TestObject('a')
    ]).distinctUnique(equals: equals, hashCode: (o) => o.key.codeUnitAt(0));

    observable.listen(expectAsync1((_TestObject actual) {
      expect(equals(actual, expected[next++]), isTrue);
    }, count: 3));
  });
}

class _TestObject {
  final String key;

  const _TestObject(this.key);

  @override
  String toString() => key;
}
