library core.promise_proxy;

import 'package:js/js.dart';

@JS()
class Promise {
  
  @JS()
  external Promise(void resolveReject(void onResolve(dynamic value), void onError(error)));
  
  @JS('resolve')
  external static Promise resolve(Promise promise, dynamic value);
  
}