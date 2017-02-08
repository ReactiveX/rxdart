import 'dart:html';
import 'package:rxdart/rxdart.dart';

void main() {

  final dragTarget = querySelector('#dragTarget');
  final mouseUp = new Observable(document.onMouseUp);
  final mouseMove = new Observable(document.onMouseMove);
  final mouseDown = new Observable(document.onMouseDown);

  mouseDown
    /// Use map() to calculate the left and top properties on mouseDown
    .map((MouseEvent e) => <String, int>{
      'left': e.client.x - dragTarget.offset.left,
      'top': e.client.y - dragTarget.offset.top
    })
    /// Use flatMapLatest() to get the mouse position on each mouseMove
    .flatMapLatest((Map<String, int> startPos) {

      return mouseMove
        /// Use map() to calculate the left and top properties on each mouseMove
        .map((MouseEvent pos) => <String, int>{
          'left': pos.client.x - startPos['left'],
          'top': pos.client.y - startPos['top']
        })
        /// Use takeUntil() to stop calculations when a mouseUp occurs
        .takeUntil(mouseUp);
    })
    /// Use listen() to update the position of the dragTarget
    .listen((Map<String, int> e) {
      dragTarget.style.top = '${e['top']}px';
      dragTarget.style.left = '${e['left']}px';
    });
}
