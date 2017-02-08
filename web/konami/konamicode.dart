import 'dart:html';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

void main() {

  const up = 38;
  const down = 40;
  const left = 37;
  const right = 39;
  const a = 65;
  const b = 66;

  /// The Konami Code: UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A
  const konamiKeyCodes = const <int>[up, up, down, down, left, right, left, right, b, a];
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