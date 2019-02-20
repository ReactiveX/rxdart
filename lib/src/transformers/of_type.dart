import 'dart:async';

import 'package:rxdart/src/utils/type_token.dart';

/// Filters a sequence so that only events of a given type pass
///
/// In order to capture the Type correctly, it needs to be wrapped
/// in a [TypeToken] as the generic parameter.
///
/// Given the way Dart generics work, one cannot simply use the `is T` / `as T`
/// checks and castings within `OfTypeStreamTransformer` itself. Therefore, the
/// [TypeToken] class was introduced to capture the type of class you'd
/// like `ofType` to filter down to.
///
/// ### Examples
///
///     new Stream.fromIterable([1, "hi"])
///       .ofType(new TypeToken<String>)
///       .listen(print); // prints "hi"
///
/// As a shortcut, you can use some pre-defined constants to write the above
/// in the following way:
///
///     new Stream.fromIterable([1, "hi"])
///       .transform(new OfTypeStreamTransformer(kString))
///       .listen(print); // prints "hi"
///
/// If you'd like to create your own shortcuts like the example above,
/// simply create a constant:
///
///     const TypeToken<Map<Int, String>> kMapIntString =
///       const TypeToken<Map<Int, String>>();
class OfTypeStreamTransformer<T, S> extends StreamTransformerBase<T, S> {
  final StreamTransformer<T, S> transformer;

  OfTypeStreamTransformer(TypeToken<S> typeToken)
      : transformer = _buildTransformer(typeToken);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      TypeToken<S> typeToken) {
    return StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              try {
                if (typeToken.isType(value)) {
                  controller.add(typeToken.toType(value));
                }
              } catch (e, s) {
                controller.addError(e, s);
              }
            },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError);
          },
          onPause: ([Future<dynamic> resumeSignal]) =>
              subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel());

      return controller.stream.listen(null);
    });
  }
}
