library core.promise_proxy;

import 'package:js/js.dart';

@Js()
class Promise {
  
  @Js()
  external Promise(void resolveReject(void onResolve(dynamic value), void onError(error)));
  
  @Js('resolve')
  external static Promise resolve(Promise promise, dynamic value);
  
}