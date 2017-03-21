import 'dart:async';

import 'package:rxdart/src/utils/type_token.dart';

/// Casts a sequence of items to a given type.
///
/// In order to capture the Type correctly, it needs to be wrapped
/// in a [TypeToken] as the generic parameter.
///
/// Given the way Dart generics work, one cannot simply use `as T`
/// checks and castings within `CastStreamTransformer` itself. Therefore, the
/// [TypeToken] class was introduced to capture the type of class you'd
/// like `cast` to convert to.
///
/// This operator is often useful when going from a more generic type to a more
/// specific type.
///
/// ### Examples
///
///     // A Stream of num, but we know the data is an int
///     new Stream<num>.fromIterable(<int>[1, 2, 3])
///       .cast(new TypeToken<int>) // So we can call `isEven`
///       .map((i) => i.isEven)
///       .listen(print); // prints "false", "true", "false"
///
/// As a shortcut, you can use some pre-defined constants to write the above
/// in the following way:
///
///     // A Stream of num, but we know the data is an int
///     new Stream<num>.fromIterable(<int>[1, 2, 3])
///       .cast(kInt) // Use the `kInt` constant as a shortcut
///       .map((i) => i.isEven)
///       .listen(print); // prints "false", "true", "false"
///
/// If you'd like to create your own shortcuts like the example above,
/// simply create a constant:
///
///     const TypeToken<Map<Int, String>> kMapIntString =
///       const TypeToken<Map<Int, String>>();
class CastStreamTransformer<T, S> implements StreamTransformer<T, S> {
  final StreamTransformer<T, S> transformer;
  CastStreamTransformer(TypeToken<S> typeToken)
      : transformer = _buildTransformer(typeToken);

  @override
  Stream<S> bind(Stream<T> stream) => transformer.bind(stream);

  static StreamTransformer<T, S> _buildTransformer<T, S>(
      TypeToken<S> typeToken) {
    return new StreamTransformer<T, S>((Stream<T> input, bool cancelOnError) {
      StreamController<S> controller;
      StreamSubscription<T> subscription;

      controller = new StreamController<S>(
          sync: true,
          onListen: () {
            subscription = input.listen((T value) {
              try {
                controller.add(typeToken.toType(value));
              } catch (e) {
                controller.addError(e);
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
