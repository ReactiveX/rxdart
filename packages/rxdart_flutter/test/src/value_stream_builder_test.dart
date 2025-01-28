import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:rxdart_flutter/src/errors.dart';

class CounterBuilderApp extends StatefulWidget {
  const CounterBuilderApp({
    required this.valueStream1,
    this.valueStream2,
    this.buildWhen,
    this.onBuild,
    Key? key,
  }) : super(key: key);

  final BehaviorSubject<int> valueStream1;
  final BehaviorSubject<int>? valueStream2;
  final ValueStreamBuilderCondition<int>? buildWhen;
  final void Function()? onBuild;

  static const materialAppKey = Key('material_app');
  static const toggleStreamButtonKey = Key('toggle_stream_button');

  @override
  State<CounterBuilderApp> createState() => _CounterBuilderAppState();
}

class _CounterBuilderAppState extends State<CounterBuilderApp> {
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
    return ValueStreamBuilder<int>(
      stream: valueStream,
      buildWhen: widget.buildWhen,
      builder: (context, value) {
        widget.onBuild?.call();
        return MaterialApp(
          key: CounterBuilderApp.materialAppKey,
          home: Column(
            children: [
              Text('$value'),
              TextButton(
                key: CounterBuilderApp.toggleStreamButtonKey,
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
  group('ValueStreamBuilder', () {
    testWidgets('renders initial value from stream', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        CounterBuilderApp(
            valueStream1: valueStream, onBuild: () => numBuilds++),
      );

      expect(find.text('0'), findsOneWidget);
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds widget when stream emits new values', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        CounterBuilderApp(
            valueStream1: valueStream, onBuild: () => numBuilds++),
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
        CounterBuilderApp(
          valueStream1: valueStream,
          buildWhen: (previous, current) => current.isOdd,
          onBuild: () => numBuilds++,
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

    testWidgets('triggers rebuild when buildWhen returns true', (tester) async {
      final valueStream = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        CounterBuilderApp(
          valueStream1: valueStream,
          buildWhen: (previous, current) => true,
          onBuild: () => numBuilds++,
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
      expect(numBuilds, 3);
      expect(find.text('2'), findsOneWidget);

      valueStream.add(3);
      await tester.pumpAndSettle();
      expect(numBuilds, 4);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('rebuilds when switching between streams', (tester) async {
      final firstStream = BehaviorSubject<int>.seeded(0);
      final secondStream = BehaviorSubject<int>.seeded(100);

      var numBuilds = 0;

      await tester.pumpWidget(
        CounterBuilderApp(
          valueStream1: firstStream,
          valueStream2: secondStream,
          onBuild: () => numBuilds++,
        ),
      );

      expect(find.text('0'), findsOneWidget);

      firstStream.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byKey(CounterBuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);

      secondStream.add(200);
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
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
        CounterBuilderApp(
          valueStream1: valueStream,
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int>>());

      expect(find.byKey(CounterBuilderApp.materialAppKey), findsNothing);
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
        CounterBuilderApp(
          valueStream1: valueStream,
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(CounterBuilderApp.materialAppKey), findsNothing);
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
        CounterBuilderApp(
          valueStream1: valueStream1,
          valueStream2: valueStream2,
        ),
      );

      expect(find.byKey(CounterBuilderApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(CounterBuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int>>());
      expect(find.byKey(CounterBuilderApp.materialAppKey), findsNothing);
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
        CounterBuilderApp(
          valueStream1: valueStream1,
          valueStream2: valueStream2,
        ),
      );

      expect(find.byKey(CounterBuilderApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(CounterBuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(CounterBuilderApp.materialAppKey), findsNothing);
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
        CounterBuilderApp(
          valueStream1: valueStream1,
        ),
      );

      expect(find.byKey(CounterBuilderApp.materialAppKey), findsOneWidget);

      valueStream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(CounterBuilderApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamBuilder(
        stream: BehaviorSubject<int>.seeded(0),
        builder: (context, value) => const SizedBox(),
        buildWhen: (previous, current) => previous != current,
      ).debugFillProperties(builder);

      final description = builder.properties
          .where((node) => !node.isFiltered(DiagnosticLevel.info))
          .map((node) => node.toString())
          .toList();

      expect(
        description,
        <String>[
          'stream: Instance of '
              "'BehaviorSubject<int>'",
          'has buildWhen',
          'has builder',
        ],
      );
    });
  });
}
