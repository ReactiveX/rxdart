import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:rxdart_flutter/src/errors.dart';

class ConsumerApp<T> extends StatefulWidget {
  const ConsumerApp({
    required this.stream1,
    this.stream2,
    this.buildWhen,
    required this.listener,
    this.onBuild,
    this.child,
    Key? key,
  }) : super(key: key);

  final ValueStream<T> stream1;
  final ValueStream<T>? stream2;
  final ValueStreamBuilderCondition<T>? buildWhen;
  final ValueStreamWidgetListener<T> listener;
  final void Function()? onBuild;
  final Widget? child;
  static const materialAppKey = Key('material_app');
  static const toggleStreamButtonKey = Key('toggle_stream_button');

  @override
  State<ConsumerApp<T>> createState() => _ConsumerAppState<T>();
}

class _ConsumerAppState<T> extends State<ConsumerApp<T>> {
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
    return ValueStreamConsumer<T>(
      stream: stream,
      isReplayValueStream: false,
      buildWhen: widget.buildWhen,
      listener: widget.listener,
      child: widget.child,
      builder: (context, value, child) {
        widget.onBuild?.call();
        return MaterialApp(
          key: ConsumerApp.materialAppKey,
          home: Column(
            children: [
              Text('$value'),
              if (child != null) child,
              TextButton(
                key: ConsumerApp.toggleStreamButtonKey,
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
  group('ValueStreamConsumer - T Non Nullable', () {
    // Builder related tests

    testWidgets('renders initial value from stream', (tester) async {
      final stream1 = ValueSubject<int>(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds widget when stream emits new values', (tester) async {
      final stream1 = ValueSubject<int>(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(numBuilds, 2);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      expect(numBuilds, 3);
    });

    testWidgets('passes child parameter to builder', (tester) async {
      final stream1 = ValueSubject<int>(0);
      const child = Text('child');

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          child: child,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('skips rebuild when buildWhen returns false', (tester) async {
      final stream1 = ValueSubject<int>(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          buildWhen: (previous, current) => current.isOdd,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(numBuilds, 1);
      expect(find.text('0'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('rebuilds when buildWhen returns true', (tester) async {
      final stream1 = ValueSubject<int>(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          buildWhen: (previous, current) => true,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(numBuilds, 1);
      expect(find.text('0'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(find.text('2'), findsOneWidget);

      stream1.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 4);
      expect(find.text('3'), findsOneWidget);
    });

    // Listener related tests

    testWidgets('does not call listener with initial value', (tester) async {
      final stream1 = ValueSubject<int>(0);
      var numCalls = 0;

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          listener: (_, previous, current) {
            numCalls++;
          },
        ),
      );

      expect(numCalls, 0);
    });

    testWidgets('calls listener when stream emits new values', (tester) async {
      final stream1 = ValueSubject<int>(0);
      var numCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        ConsumerApp<int>(
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

    // Combined functionality tests

    testWidgets(
        'calls listener and rebuilds correctly when switching between streams',
        (tester) async {
      final stream1 = ValueSubject<int>(0);
      final stream2 = ValueSubject<int>(100);
      var numBuilds = 0;
      var numListenerCalls = 0;
      final previousValues = <int>[];
      final currentValues = <int>[];

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          stream2: stream2,
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

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(numBuilds, 2);
      expect(numListenerCalls, 1);
      expect(previousValues, [0]);
      expect(currentValues, [1]);

      await tester.tap(find.byKey(ConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      expect(numBuilds, 4);
      expect(numListenerCalls, 2);
      expect(previousValues, [0, 1]);
      expect(currentValues, [1, 100]);

      stream2.add(200);
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
      final stream1 = ValueSubject<int>(0);
      var numBuilds = 0;
      var numListenerCalls = 0;

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          buildWhen: (previous, current) => current.isOdd,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) => numListenerCalls++,
        ),
      );

      expect(numBuilds, 1);
      expect(numListenerCalls, 0);
      expect(find.text('0'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 1);
      expect(find.text('1'), findsOneWidget);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(3);
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
      final stream1 = BehaviorSubject<int>();

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int>>());

      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
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
        ConsumerApp<int>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when switching to stream without value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = ValueSubject<int>(0);
      final stream2 = BehaviorSubject<int>();

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ConsumerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int>>());
      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws UnhandledStreamError when switching to stream with error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = ValueSubject<int>(0);
      final stream2 = BehaviorSubject<int>();
      stream2.addError(Exception());

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ConsumerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when stream emits error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = ValueSubject<int>(0);

      await tester.pumpWidget(
        ConsumerApp<int>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ConsumerApp.materialAppKey), findsOneWidget);

      stream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamConsumer<int>(
        stream: ValueSubject<int>(0),
        isReplayValueStream: false,
        builder: (context, value, child) => const SizedBox(),
        listener: (context, previous, current) {},
        buildWhen: (previous, current) => previous != current,
        child: const SizedBox(),
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(
        description,
        <String>[
          "stream: Instance of 'ValueSubject<int>'",
          'isReplayValueStream: false',
          'has builder',
          'has buildWhen',
          'has listener',
          'has child',
        ],
      );
    });
  });

  group('ValueStreamConsumer - T Nullable', () {
    // Builder related tests

    testWidgets('renders initial value from stream', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.text('null'), findsOneWidget);
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds widget when stream emits new values', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(numBuilds, 2);

      stream1.add(null);
      await tester.pumpAndSettle();
      expect(find.text('null'), findsOneWidget);
      expect(numBuilds, 3);
    });

    testWidgets('passes child parameter to builder', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      const child = Text('child');

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          child: child,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.text('null'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('skips rebuild when buildWhen returns false', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numBuilds = 0;

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          buildWhen: (previous, current) => current != null && current.isOdd,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(numBuilds, 1);
      expect(find.text('null'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(null);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('rebuilds when buildWhen returns true', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          buildWhen: (previous, current) => true,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) {},
        ),
      );

      expect(numBuilds, 1);
      expect(find.text('null'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(find.text('2'), findsOneWidget);

      stream1.add(null);
      await tester.pumpAndSettle();
      expect(numBuilds, 4);
      expect(find.text('null'), findsOneWidget);

      stream1.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 5);
      expect(find.text('3'), findsOneWidget);
    });

    // Listener related tests

    testWidgets('does not call listener with initial value', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numCalls = 0;

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          listener: (_, previous, current) {
            numCalls++;
          },
        ),
      );

      expect(numCalls, 0);
    });

    testWidgets('calls listener when stream emits new values', (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numCalls = 0;
      final previousValues = <int?>[];
      final currentValues = <int?>[];

      await tester.pumpWidget(
        ConsumerApp<int?>(
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

    // Combined functionality tests

    testWidgets(
        'calls listener and rebuilds correctly when switching between streams',
        (tester) async {
      final stream1 = ValueSubject<int?>(null);
      final stream2 = ValueSubject<int?>(null);
      var numBuilds = 0;
      var numListenerCalls = 0;
      final previousValues = <int?>[];
      final currentValues = <int?>[];

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          stream2: stream2,
          onBuild: () => numBuilds++,
          listener: (_, previous, current) {
            numListenerCalls++;
            previousValues.add(previous);
            currentValues.add(current);
          },
        ),
      );

      expect(find.text('null'), findsOneWidget);
      expect(numBuilds, 1);
      expect(numListenerCalls, 0);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(numBuilds, 2);
      expect(numListenerCalls, 1);
      expect(previousValues, [null]);
      expect(currentValues, [1]);

      await tester.tap(find.byKey(ConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('null'), findsOneWidget);
      expect(numBuilds, 4);
      expect(numListenerCalls, 2);
      expect(previousValues, [null, 1]);
      expect(currentValues, [1, null]);

      stream2.add(200);
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
      expect(numBuilds, 5);
      expect(numListenerCalls, 3);
      expect(previousValues, [null, 1, null]);
      expect(currentValues, [1, null, 200]);
    });

    testWidgets(
        'buildWhen affects only rebuilds while listener is always called',
        (tester) async {
      final stream1 = ValueSubject<int?>(null);
      var numBuilds = 0;
      var numListenerCalls = 0;

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          buildWhen: (previous, current) => current != null && current.isOdd,
          onBuild: () => numBuilds++,
          listener: (_, __, ___) => numListenerCalls++,
        ),
      );

      expect(numBuilds, 1);
      expect(numListenerCalls, 0);
      expect(find.text('null'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 1);
      expect(find.text('1'), findsOneWidget);

      stream1.add(2);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 2);
      expect(find.text('1'), findsOneWidget);

      stream1.add(null);
      await tester.pumpAndSettle();
      expect(numBuilds, 2);
      expect(numListenerCalls, 3);
      expect(find.text('1'), findsOneWidget);

      stream1.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 3);
      expect(numListenerCalls, 4);
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
      final stream1 = BehaviorSubject<int?>();

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int?>>());

      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
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
        ConsumerApp<int?>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws ValueStreamHasNoValueError when switching to stream without value',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = ValueSubject<int?>(null);
      final stream2 = BehaviorSubject<int?>();

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ConsumerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int?>>());
      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets(
        'throws UnhandledStreamError when switching to stream with error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = ValueSubject<int?>(null);
      final stream2 = BehaviorSubject<int?>();
      stream2.addError(Exception());

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          stream2: stream2,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ConsumerApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(ConsumerApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('throws UnhandledStreamError when stream emits error',
        (tester) async {
      final completer = Completer<Object>();
      FlutterError.onError = (errorDetails) {
        completer.complete(errorDetails.exception);
      };
      final stream1 = ValueSubject<int?>(null);

      await tester.pumpWidget(
        ConsumerApp<int?>(
          stream1: stream1,
          listener: (_, __, ___) {},
        ),
      );

      expect(find.byKey(ConsumerApp.materialAppKey), findsOneWidget);

      stream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(ConsumerApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamConsumer<int?>(
        stream: ValueSubject<int?>(null),
        isReplayValueStream: false,
        builder: (context, value, child) => const SizedBox(),
        listener: (context, previous, current) {},
        buildWhen: (previous, current) => previous != current,
        child: const SizedBox(),
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(
        description,
        <String>[
          "stream: Instance of 'ValueSubject<int?>'",
          'isReplayValueStream: false',
          'has builder',
          'has buildWhen',
          'has listener',
          'has child',
        ],
      );
    });
  });
}
