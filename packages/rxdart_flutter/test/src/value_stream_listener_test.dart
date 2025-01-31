import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:rxdart_flutter/src/errors.dart';

typedef Value<T> = void Function(T previous, T current);

class ListenerApp<T> extends StatefulWidget {
  const ListenerApp({
    required this.stream1,
    this.stream2,
    required this.listener,
    Key? key,
  }) : super(key: key);

  final ValueStream<T> stream1;
  final ValueStream<T>? stream2;
  final ValueStreamWidgetListener<T> listener;

  static const materialAppKey = Key('material_app');
  static const toggleStreamButtonKey = Key('toggle_stream_button');

  @override
  State<ListenerApp<T>> createState() => _ListenerAppState<T>();
}

class _ListenerAppState<T> extends State<ListenerApp<T>> {
  late ValueStream<T> stream;

  @override
  void initState() {
    super.initState();
    stream = widget.stream1;
  }

  void toggleStream() {
    setState(() {
      if (widget.stream2 != null) {
        if (widget.stream2 == stream) {
          stream = widget.stream1;
        } else {
          stream = widget.stream2!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueStreamListener<T>(
      stream: stream,
      listener: widget.listener,
      child: MaterialApp(
        key: ListenerApp.materialAppKey,
        home: Column(
          children: [
            TextButton(
              key: ListenerApp.toggleStreamButtonKey,
              child: const Text('Toggle Stream'),
              onPressed: toggleStream,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('ValueStreamListener - T Non Nullable', () {
    testWidgets('does not call listener with initial value', (tester) async {
      final stream1 = BehaviorSubject<int>.seeded(0);
      var numCalls = 0;

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          listener: (_, previous, current) {
            numCalls++;
          },
        ),
      );

      expect(numCalls, 0);
    });

    testWidgets('calls listener when stream emits new values', (tester) async {
      final stream1 = BehaviorSubject<int>.seeded(0);
      var numCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          listener: (_, previous, current) {
            numCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numCalls, 1);
      expect(previousValues, [0]);
      expect(currentValues, [1]);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numCalls, 2);
      expect(previousValues, [0, 1]);
      expect(currentValues, [1, 2]);
    });

    testWidgets('calls listener with correct values when switching streams',
        (tester) async {
      final stream1 = BehaviorSubject<int>.seeded(0);
      final stream2 = BehaviorSubject<int>.seeded(100);
      var numCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, previous, current) {
            numCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numCalls, 1);
      expect(previousValues, [0]);
      expect(currentValues, [1]);

      await tester.tap(find.byKey(ListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(numCalls, 2);
      expect(previousValues, [0, 1]);
      expect(currentValues, [1, 100]);

      stream2.add(200);
      await tester.pumpAndSettle();
      expect(numCalls, 3);
      expect(previousValues, [0, 1, 100]);
      expect(currentValues, [1, 100, 200]);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when initial stream has no value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int>();

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int>>());

      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when initial stream has error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int>();
      stream1.addError(Exception());
      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when switching to stream without value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int>.seeded(0);
      final stream2 = BehaviorSubject<int>();

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ListenerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int>>());
      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws UnhandledStreamError when switching to stream with error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int>.seeded(0);
      final stream2 = BehaviorSubject<int>();
      stream2.addError(Exception());

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ListenerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when stream emits error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int>.seeded(0);

      await tester.pumpWidget(
        ListenerApp<int>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ListenerApp.materialAppKey), findsOneWidget);

      stream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamListener(
        stream: BehaviorSubject<int>.seeded(0),
        listener: (context, previous, current) {},
        child: const SizedBox(),
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(
        description,
        <String>[
          "stream: Instance of 'BehaviorSubject<int>'",
          'has listener',
          'has child',
        ],
      );
    });
  });

  group('ValueStreamListener - T Nullable', () {
    testWidgets('does not call listener with initial value', (tester) async {
      final stream1 = BehaviorSubject<int?>.seeded(null);
      var numCalls = 0;

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          listener: (_, previous, current) {
            numCalls++;
          },
        ),
      );

      expect(numCalls, 0);
    });

    testWidgets('calls listener when stream emits new values', (tester) async {
      final stream1 = BehaviorSubject<int?>.seeded(null);
      var numCalls = 0;
      final previousValues = <int?>[];
      final currentValues = <int?>[];

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          listener: (_, previous, current) {
            numCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numCalls, 1);
      expect(previousValues, [null]);
      expect(currentValues, [1]);

      stream1.add(null);
      await tester.pumpAndSettle();
      expect(numCalls, 2);
      expect(previousValues, [null, 1]);
      expect(currentValues, [1, null]);
    });

    testWidgets('calls listener with correct values when switching streams',
        (tester) async {
      final stream1 = BehaviorSubject<int?>.seeded(null);
      final stream2 = BehaviorSubject<int?>.seeded(null);
      var numCalls = 0;
      final previousValues = <int?>[];
      final currentValues = <int?>[];

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, previous, current) {
            numCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numCalls, 1);
      expect(previousValues, [null]);
      expect(currentValues, [1]);

      await tester.tap(find.byKey(ListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(numCalls, 2);
      expect(previousValues, [null, 1]);
      expect(currentValues, [1, null]);

      stream2.add(200);
      await tester.pumpAndSettle();
      expect(numCalls, 3);
      expect(previousValues, [null, 1, null]);
      expect(currentValues, [1, null, 200]);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when initial stream has no value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int?>();

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int?>>());

      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when initial stream has error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int?>();
      stream1.addError(Exception());
      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when switching to stream without value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int?>.seeded(null);
      final stream2 = BehaviorSubject<int?>();

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ListenerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int?>>());
      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws UnhandledStreamError when switching to stream with error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int?>.seeded(null);
      final stream2 = BehaviorSubject<int?>();
      stream2.addError(Exception());

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ListenerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when stream emits error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = BehaviorSubject<int?>.seeded(null);

      await tester.pumpWidget(
        ListenerApp<int?>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ListenerApp.materialAppKey), findsOneWidget);

      stream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamListener(
        stream: BehaviorSubject<int?>.seeded(null),
        listener: (context, previous, current) {},
        child: const SizedBox(),
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(
        description,
        <String>[
          "stream: Instance of 'BehaviorSubject<int?>'",
          'has listener',
          'has child',
        ],
      );
    });
  });
}
