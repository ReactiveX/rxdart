import 'dart:html';
import 'dart:async';

import 'package:rxdart/rxdart.dart';

Observable<MouseEvent> _getMouseObservable(String mouseEvent) {

  // Instantiate a StreamController
  final StreamController<MouseEvent> controller = new StreamController<MouseEvent>.broadcast();

  // Listen to the DOM for mouseEvents
  // and add each event to the streamController
  document.body.addEventListener(mouseEvent, (Event event) => controller.add(event));

  // Print the mouseEvent each time a stream gets cancelled
  controller.onCancel = () {
    print('CANCELED ' + mouseEvent);
  };

  // Convert the streamController's stream to an Observable
  // and return it
  return new Observable<MouseEvent>(controller.stream);
}

void main() {
  final Element dragTarget = querySelector('#dragTarget');

  Observable<MouseEvent> mouseUp = _getMouseObservable('mouseup');
  Observable<MouseEvent> mouseMove = _getMouseObservable('mousemove');
  Observable<MouseEvent> mouseDown = _getMouseObservable('mousedown');

  mouseDown
    // Use map() to Calculate the left and top properties on mouseDown
    .map((MouseEvent e) => <String, int>{
      'left': e.client.x - dragTarget.offset.left,
      'top': e.client.y - dragTarget.offset.top
    })
    // Use flatMapLatest() to get the mouse position on each mouseMove
    .flatMapLatest((Map<String, int> startPos) {

      return mouseMove
        // Use map() to calculate the left and top properties on each mouseMove
        .map((MouseEvent pos) => <String, int>{
          'left': pos.client.x - startPos['left'],
          'top': pos.client.y - startPos['top']
        })
        // Use takeUntil() to stop calculations when a mouseUp occurs
        .takeUntil(mouseUp);
    })
    // Use listen() to update the position of the dragTarget
    .listen((Map<String, int> e) {
      dragTarget.style.top = '${e['top']}px';
      dragTarget.style.left = '${e['left']}px';
    });
}
