import 'dart:async';

Stream<num> getErroneousStream() {
  StreamController<num> controller = new StreamController<num>();

  controller.addError(new Exception());
  controller.close();

  return controller.stream;
}
