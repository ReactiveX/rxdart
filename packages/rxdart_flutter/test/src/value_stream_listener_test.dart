import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:rxdart_flutter/src/errors.dart';

class CounterListenerApp extends StatefulWidget {
  const CounterListenerApp({
    required this.valueStream1,
    this.valueStream2,
    required this.listener,
    Key? key,
  }) : super(key: key);

  final BehaviorSubject<int> valueStream1;
  final BehaviorSubject<int>? valueStream2;
  final ValueStreamWidgetListener<int> listener;

  static const materialAppKey = Key('material_app');
  static const toggleStreamButtonKey = Key('toggle_stream_button');

  @override
  State<CounterListenerApp> createState() => _CounterListenerAppState();
}

class _CounterListenerAppState extends State<CounterListenerApp> {
  late BehaviorSubject<int> valueStream;

  @override
  void initState() {
    super.initState();
    valueStream = widget.valueStream1;
  }

  @override
  void dispose() {
    widget.valueStream1.close();
    widget.valueStream2?.close();
    super.dispose();
  }

  void toggleStream() {
    setState(() {
      if (widget.valueStream2 != null) {
        if (widget.valueStream2 == valueStream) {
          valueStream = widget.valueStream1;
        } else {
          valueStream = widget.valueStream2!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueStreamListener<int>(
      stream: valueStream,
      listener: widget.listener,
      child: MaterialApp(
        key: CounterListenerApp.materialAppKey,
        home: Column(
          children: [
            TextButton(
              key: CounterListenerApp.toggleStreamButtonKey,
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
  group('ValueStreamListener', () {
    testWidgets('does not call listener with initial value', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numCalls = 0;
      var lastPrevious = -1;
      var lastCurrent = -1;

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream,
          listener: (_, previous, current) {
            numCalls++;
            lastPrevious = previous;
            lastCurrent = current;
          },
        ),
      );

      expect(numCalls, 0);
      expect(lastPrevious, -1);
      expect(lastCurrent, -1);
    });

    testWidgets('calls listener when stream emits new values', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream,
          listener: (_, previous, current) {
            numCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      valueStream.add(1);
      await tester.pumpAndSettle();
      expect(numCalls, 1);
      expect(previousValues, [0]);
      expect(currentValues, [1]);

      valueStream.add(2);
      await tester.pumpAndSettle();
      expect(numCalls, 2);
      expect(previousValues, [0, 1]);
      expect(currentValues, [1, 2]);
    });

    testWidgets('calls listener with correct values when switching streams',
        (tester) async {
      final firstStream = BehaviorSubject<int>.seeded(0);
      final secondStream = BehaviorSubject<int>.seeded(100);
      var numCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: firstStream,
          valueStream2: secondStream,
          listener: (_, previous, current) {
            numCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      firstStream.add(1);
      await tester.pumpAndSettle();
      expect(numCalls, 1);
      expect(previousValues, [0]);
      expect(currentValues, [1]);

      await tester.tap(find.byKey(CounterListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(numCalls, 2);
      expect(previousValues, [0, 1]);
      expect(currentValues, [1, 100]);

      secondStream.add(200);
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
      final valueStream = BehaviorSubject<int>();

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int>>());

      expect(find.byKey(CounterListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when initial stream has error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final valueStream = BehaviorSubject<int>();
      valueStream.addError(Exception());
      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(CounterListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when switching to stream without value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final valueStream1 = BehaviorSubject<int>.seeded(0);
      final valueStream2 = BehaviorSubject<int>();

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream1,
          valueStream2: valueStream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(CounterListenerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(CounterListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int>>());
      expect(find.byKey(CounterListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws UnhandledStreamError when switching to stream with error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final valueStream1 = BehaviorSubject<int>.seeded(0);
      final valueStream2 = BehaviorSubject<int>();
      valueStream2.addError(Exception());

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream1,
          valueStream2: valueStream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(CounterListenerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(CounterListenerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(CounterListenerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when stream emits error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final valueStream1 = BehaviorSubject<int>.seeded(0);

      await tester.pumpWidget(
        CounterListenerApp(
          valueStream1: valueStream1,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(CounterListenerApp.materialAppKey), findsOneWidget);

      valueStream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(CounterListenerApp.materialAppKey), findsNothing);
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
}
