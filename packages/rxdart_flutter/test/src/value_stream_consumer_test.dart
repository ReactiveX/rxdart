import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:rxdart_flutter/src/errors.dart';

class CounterConsumerApp extends StatefulWidget {
  const CounterConsumerApp({
    required this.valueStream1,
    this.valueStream2,
    this.buildWhen,
    required this.listener,
    this.onBuild,
    Key? key,
  }) : super(key: key);

  final BehaviorSubject<int> valueStream1;
  final BehaviorSubject<int>? valueStream2;
  final ValueStreamBuilderCondition<int>? buildWhen;
  final ValueStreamWidgetListener<int> listener;
  final void Function()? onBuild;

  static const materialAppKey = Key('material_app');
  static const toggleStreamButtonKey = Key('toggle_stream_button');

  @override
  State<CounterConsumerApp> createState() => _CounterConsumerAppState();
}

class _CounterConsumerAppState extends State<CounterConsumerApp> {
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
    return ValueStreamConsumer<int>(
      stream: valueStream,
      buildWhen: widget.buildWhen,
      listener: widget.listener,
      builder: (context, value) {
        widget.onBuild?.call();
        return MaterialApp(
          key: CounterConsumerApp.materialAppKey,
          home: Column(
            children: [
              Text('$value'),
              TextButton(
                key: CounterConsumerApp.toggleStreamButtonKey,
                child: const Text('Toggle Stream'),
                onPressed: toggleStream,
              ),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  group('ValueStreamConsumer', () {
    // Builder related tests
    testWidgets('renders initial value from stream', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        CounterConsumerApp(
          valueStream1: valueStream,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds widget when stream emits new values', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        CounterConsumerApp(
          valueStream1: valueStream,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      valueStream.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(numBuilds, 2);

      valueStream.add(2);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      expect(numBuilds, 3);
    });

    testWidgets('skips rebuild when buildWhen returns false', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        CounterConsumerApp(
          valueStream1: valueStream,
          buildWhen: (previous, current) => current.isOdd,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(numBuilds, 1);
      expect(find.text('0'), findsOneWidget);

      valueStream.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      valueStream.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      valueStream.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(find.text('3'), findsOneWidget);
    });

    // Listener related tests
    testWidgets('does not call listener with initial value', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numCalls = 0;
      var lastPrevious = -1;
      var lastCurrent = -1;

      await tester.pumpWidget(
        CounterConsumerApp(
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
        CounterConsumerApp(
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

    // Combined functionality tests
    testWidgets(
        'calls listener and rebuilds correctly when switching between streams',
        (tester) async {
      final firstStream = BehaviorSubject<int>.seeded(0);
      final secondStream = BehaviorSubject<int>.seeded(100);
      var numBuilds = 0;
      var numListenerCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        CounterConsumerApp(
          valueStream1: firstStream,
          valueStream2: secondStream,
          onBuild: () => numBuilds++,
          listener: (_, previous, current) {
            numListenerCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(numBuilds, 1);
      expect(numListenerCalls, 0);

      firstStream.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(numBuilds, 2);
      expect(numListenerCalls, 1);
      expect(previousValues, [0]);
      expect(currentValues, [1]);

      await tester.tap(find.byKey(CounterConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      // Increment numBuilds by 2:
      // * 1. when toggle stream button is pressed triggers a rebuild
      // * 2. when stream is switched and triggers a rebuild
      expect(numBuilds, 4);
      expect(numListenerCalls, 2);
      expect(previousValues, [0, 1]);
      expect(currentValues, [1, 100]);

      secondStream.add(200);
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
      expect(numBuilds, 5);
      expect(numListenerCalls, 3);
      expect(previousValues, [0, 1, 100]);
      expect(currentValues, [1, 100, 200]);
    });

    testWidgets(
        'buildWhen affects only rebuilds while listener is always called',
        (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      var numListenerCalls = 0;

      await tester.pumpWidget(
        CounterConsumerApp(
          valueStream1: valueStream,
          buildWhen: (previous, current) => current.isOdd,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) => numListenerCalls++,
        ),
      );

      expect(numBuilds, 1);
      expect(numListenerCalls, 0);
      expect(find.text('0'), findsOneWidget);

      valueStream.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 1);
      expect(find.text('1'), findsOneWidget);

      valueStream.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 2);
      expect(find.text('1'), findsOneWidget);

      valueStream.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(numListenerCalls, 3);
      expect(find.text('3'), findsOneWidget);
    });

    // Error handling tests
    testWidgets(
        'throws ValueStreamHasNoValueError when initial stream has no value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final valueStream = BehaviorSubject<int>();

      await tester.pumpWidget(
        CounterConsumerApp(
          valueStream1: valueStream,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int>>());

      expect(find.byKey(CounterConsumerApp.materialAppKey), findsNothing);
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
        CounterConsumerApp(
          valueStream1: valueStream,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(CounterConsumerApp.materialAppKey), findsNothing);
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
        CounterConsumerApp(
          valueStream1: valueStream1,
          valueStream2: valueStream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(CounterConsumerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(CounterConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int>>());
      expect(find.byKey(CounterConsumerApp.materialAppKey), findsNothing);
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
        CounterConsumerApp(
          valueStream1: valueStream1,
          valueStream2: valueStream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(CounterConsumerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(CounterConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(CounterConsumerApp.materialAppKey), findsNothing);
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
        CounterConsumerApp(
          valueStream1: valueStream1,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(CounterConsumerApp.materialAppKey), findsOneWidget);

      valueStream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(CounterConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamConsumer(
        stream: BehaviorSubject<int>.seeded(0),
        builder: (context, value) => const SizedBox(),
        listener: (context, previous, current) {},
        buildWhen: (previous, current) => previous != current,
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(
        description,
        <String>[
          "stream: Instance of 'BehaviorSubject<int>'",
          'has builder',
          'has buildWhen',
          'has listener',
        ],
      );
    });
  });
}
