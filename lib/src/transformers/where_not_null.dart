import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';

class _WhereNotNullStreamSink<T extends Object>
    with ForwardingSinkMixin<T?, T>
    implements ForwardingSink<T?, T> {
  @override
  void add(EventSink<T> sink, T? data) {
    if (data != null) {
      sink.add(data);
    }
  }
}

class WhereNotNullStreamTransformer<T extends Object>
    extends StreamTransformerBase<T?, T> {
  @override
  Stream<T> bind(Stream<T?> stream) =>
      forwardStream(stream, _WhereNotNullStreamSink<T>());
}

extension WhereNotNullExtension<T extends Object> on Stream<T?> {
  Stream<T> whereNotNull() => forwardStream(this, _WhereNotNullStreamSink<T>());
}

void main() {
  Stream.fromIterable(<int?>[1, 2, null, 3, 4]).whereNotNull().listen(print);
}
