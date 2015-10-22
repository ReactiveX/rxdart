@JS('Rx')
library rx.disposable_proxy;

import 'package:js/js.dart';

@JS()
class Disposable {
  
  @JS()
  external Disposable();
  
  @JS('dispose')
  external dispose();
  
}