import 'dart:html';
import 'dart:async';

import 'package:rxdart/rxdart.dart' as rx;

rx.Observable<MouseEvent> _getMouseObservable(String mouseEvent) {
  final StreamController<MouseEvent> controller = new StreamController<MouseEvent>.broadcast();

  document.body.addEventListener(mouseEvent, (Event event) => controller.add(event));

  return rx.observable(controller.stream);
}

void main() {
  final Element dragTarget = querySelector('#dragTarget');
  
  rx.Observable<MouseEvent> mouseUp = _getMouseObservable('mouseup');
  rx.Observable<MouseEvent> mouseMove = _getMouseObservable('mousemove');
  rx.Observable<Map<String, int>> mouseDown = _getMouseObservable('mousedown')
    .map((MouseEvent e) {
      e.preventDefault();
      
      return <String, int>{ 'left': e.client.x - dragTarget.offset.left, 'top': e.client.y - dragTarget.offset.top };
    });
  
  mouseDown.flatMap(
      (Map<String, int> e) => mouseMove
        .map((MouseEvent pos) => <String, int>{ 'left': pos.client.x - e['left'], 'top': pos.client.y - e['top'] })
        .takeUntil(mouseUp))
      .listen((Map<String, int> e) {
        dragTarget.style.top = '${e['top']}px';
        dragTarget.style.left = '${e['left']}px';
      });
}