import 'dart:html';

import 'package:rxdart/rxdart.dart' as Rx;

void main() {
  final Element dragTarget = querySelector('#dragTarget');
  
  Rx.Observable<MouseEvent> mouseUp = new Rx.Observable<MouseEvent>.fromEvent(dragTarget, 'mouseup');
  Rx.Observable<MouseEvent> mouseMove = new Rx.Observable<MouseEvent>.fromEvent(dragTarget, 'mousemove');
  Rx.Observable<Map<String, int>> mouseDown = new Rx.Observable<MouseEvent>.fromEvent(dragTarget, 'mousedown')
    .map((e) {
      e.preventDefault();
      
      return { 'left': e.client.x - dragTarget.offset.left, 'top': e.client.y - dragTarget.offset.top };
    });
  
  mouseDown.flatMap(
      (Map<String, int> e) => mouseMove.map(
          (MouseEvent pos) => { 'left': pos.client.x - e['left'], 'top': pos.client.y - e['top'] } 
      ).takeUntil(mouseUp))
       .subscribe((e) {
          dragTarget.style.top = '${e['top']}px';
          dragTarget.style.left = '${e['left']}px';
       });
}