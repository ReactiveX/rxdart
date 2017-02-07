import 'dart:async';
import 'dart:html';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

void main() {

  // The Konami Code: UP, UP, DOWN, DOWN, LEFT, RIGHT, LEFT, RIGHT, B, A
  const codes = const <int>[38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
  final result = querySelector('#result');
  final keyboardInput$ctrl = new StreamController<KeyboardEvent>();
  final keyboardInput$ = new Observable(keyboardInput$ctrl.stream);

  // Listen to the DOM for the 'keyup' event
  // and it to the streamController each time it occurs
  document.addEventListener('keyup', (event) => keyboardInput$ctrl.add(event));

  keyboardInput$
    // Use map() to get the keyCode
    .map((event) => event.keyCode)
    // Use bufferWithCount() to remember the last 10 keyCodes
    .bufferWithCount(10, 1)
    // Use where() to check for matching values
    .where((list) => const IterableEquality<int>().equals(list, codes))
    // Use listen() to display the result
    .listen((_) => result.innerHtml = 'KONAMI!');
}