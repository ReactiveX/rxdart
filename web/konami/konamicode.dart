import 'dart:html';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

void main() {

  const konamiKeyCodes = const <int>[
    KeyCode.UP,
    KeyCode.UP,
    KeyCode.DOWN,
    KeyCode.DOWN,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.B,
    KeyCode.A
  ];

  final result = querySelector('#result');

  /// Wrap the `document.onKeyUp` stream so we can use the methods on `Observable
  new Observable(document.onKeyUp)
    /// Use map() to get the keyCode
    .map((event) => event.keyCode)
    /// Use bufferWithCount() to remember the last 10 keyCodes
    .bufferWithCount(10, 1)
    /// Use where() to check for matching values
    .where((lastTenKeyCodes) => const IterableEquality<int>().equals(lastTenKeyCodes, konamiKeyCodes))
    /// Use listen() to display the result
    .listen((_) => result.innerHtml = 'KONAMI!');
}