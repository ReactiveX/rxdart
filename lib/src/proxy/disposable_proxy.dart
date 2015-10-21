@Js('Rx')
library rx.disposable_proxy;

import 'package:js/js.dart';

@Js()
class Disposable {
  
  @Js()
  external Disposable();
  
  @Js('dispose')
  external dispose();
  
}