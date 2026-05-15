import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:rxdart_flutter/src/errors.dart';

class BuilderApp<T> extends StatefulWidget {
  const BuilderApp({
    required this.stream1,
    this.stream2,
    this.buildWhen,
    this.onBuild,
    this.child,
    Key? key,
  }) : super(key: key);

  final ValueStream<T> stream1;
  final ValueStream<T>? stream2;
  final ValueStreamBuilderCondition<T>? buildWhen;
  final void Function()? onBuild;
  final Widget? child;

  static const materialAppKey = Key('material_app');
  static const toggleStreamButtonKey = Key('toggle_stream_button');

  @override
  State<BuilderApp<T>> createState() => _BuilderAppState<T>();
}

class _BuilderAppState<T> extends State<BuilderApp<T>> {
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
    return ValueStreamBuilder<T>(
      stream: stream,
      buildWhen: widget.buildWhen,
      child: widget.child,
      builder: (context, value, child) {
        widget.onBuild?.call();
        return MaterialApp(
          key: BuilderApp.materialAppKey,
          home: Column(
            children: [
              Text('$value'),
              if (child != null) child,
              TextButton(
                key: BuilderApp.toggleStreamButtonKey,
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
    testWidgets('renders initial value from stream - T Non Nullable',
        (tester) async {
      final stream1 = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int>(stream1: stream1, onBuild: () => numBuilds++),
      );

      expect(find.text('0'), findsOneWidget);
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds widget when stream emits new values', (tester) async {
      final stream1 = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int>(stream1: stream1, onBuild: () => numBuilds++),
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
      final stream1 = BehaviorSubject<int>.seeded(0);
      const child = Text('child');

      await tester.pumpWidget(
        BuilderApp<int>(
          stream1: stream1,
          child: child,
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
      final stream1 = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int>(
          stream1: stream1,
          buildWhen: (previous, current) => current.isOdd,
          onBuild: () => numBuilds++,
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
      final stream1 = BehaviorSubject<int>.seeded(0);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int>(
          stream1: stream1,
          buildWhen: (previous, current) => true,
          onBuild: () => numBuilds++,
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

    testWidgets('rebuilds when switching between streams', (tester) async {
      final stream1 = BehaviorSubject<int>.seeded(0);
      final stream2 = BehaviorSubject<int>.seeded(100);

      var numBuilds = 0;

      await tester.pumpWidget(
        BuilderApp<int>(
          stream1: stream1,
          stream2: stream2,
          onBuild: () => numBuilds++,
        ),
      );

      expect(find.text('0'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byKey(BuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);

      stream2.add(200);
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
      final stream1 = BehaviorSubject<int>();

      await tester.pumpWidget(
        BuilderApp<int>(
          stream1: stream1,
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int>>());

      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int>(
          stream1: stream1,
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int>(
          stream1: stream1,
          stream2: stream2,
        ),
      );

      expect(find.byKey(BuilderApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(BuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int>>());
      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int>(
          stream1: stream1,
          stream2: stream2,
        ),
      );

      expect(find.byKey(BuilderApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(BuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int>(
          stream1: stream1,
        ),
      );

      expect(find.byKey(BuilderApp.materialAppKey), findsOneWidget);

      stream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamBuilder<int>(
        stream: BehaviorSubject<int>.seeded(0),
        builder: (context, value, child) => const SizedBox(),
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
          'stream: Instance of '
              "'BehaviorSubject<int>'",
          'isReplayValueStream: true',
          'has buildWhen',
          'has builder',
          'has child',
        ],
      );
    });
  });

  group('ValueStreamBuilder - T Nullable', () {
    testWidgets('renders initial value from stream - T Nullable',
        (tester) async {
      final stream1 = BehaviorSubject<int?>.seeded(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int?>(stream1: stream1, onBuild: () => numBuilds++),
      );

      expect(find.text('null'), findsOneWidget);
      expect(numBuilds, 1);
    });

    testWidgets('rebuilds widget when stream emits new values', (tester) async {
      final stream1 = BehaviorSubject<int?>.seeded(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int?>(stream1: stream1, onBuild: () => numBuilds++),
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
      final stream1 = BehaviorSubject<int?>.seeded(null);
      const child = Text('child');

      await tester.pumpWidget(
        BuilderApp<int?>(
          stream1: stream1,
          child: child,
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
      final stream1 = BehaviorSubject<int?>.seeded(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int?>(
          stream1: stream1,
          buildWhen: (previous, current) => current != null && current.isOdd,
          onBuild: () => numBuilds++,
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
      final stream1 = BehaviorSubject<int?>.seeded(null);
      var numBuilds = 0;
      await tester.pumpWidget(
        BuilderApp<int?>(
          stream1: stream1,
          buildWhen: (previous, current) => true,
          onBuild: () => numBuilds++,
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

    testWidgets('rebuilds when switching between streams', (tester) async {
      final stream1 = BehaviorSubject<int?>.seeded(null);
      final stream2 = BehaviorSubject<int?>.seeded(null);

      var numBuilds = 0;

      await tester.pumpWidget(
        BuilderApp<int?>(
          stream1: stream1,
          stream2: stream2,
          onBuild: () => numBuilds++,
        ),
      );

      expect(find.text('null'), findsOneWidget);

      stream1.add(1);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byKey(BuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('null'), findsOneWidget);

      stream2.add(200);
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
      final stream1 = BehaviorSubject<int?>();

      await tester.pumpWidget(
        BuilderApp<int?>(
          stream1: stream1,
        ),
      );

      final error = await completer.future;
      expect(error, isA<ValueStreamHasNoValueError<int?>>());

      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int?>(
          stream1: stream1,
        ),
      );

      final error = await completer.future;
      expect(error, isA<UnhandledStreamError>());

      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int?>(
          stream1: stream1,
          stream2: stream2,
        ),
      );

      expect(find.byKey(BuilderApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(BuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<ValueStreamHasNoValueError<int?>>());
      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int?>(
          stream1: stream1,
          stream2: stream2,
        ),
      );

      expect(find.byKey(BuilderApp.materialAppKey), findsOneWidget);

      await tester.tap(find.byKey(BuilderApp.toggleStreamButtonKey));
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
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
        BuilderApp<int?>(
          stream1: stream1,
        ),
      );

      expect(find.byKey(BuilderApp.materialAppKey), findsOneWidget);

      stream1.addError(Exception());
      await tester.pumpAndSettle();

      final error = await completer.future;

      expect(error, isA<UnhandledStreamError>());
      expect(find.byKey(BuilderApp.materialAppKey), findsNothing);
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    testWidgets('provides debug properties for diagnostics', (tester) async {
      final builder = DiagnosticPropertiesBuilder();

      ValueStreamBuilder<int?>(
        stream: BehaviorSubject<int?>.seeded(null),
        builder: (context, value, child) => const SizedBox(),
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
          "stream: Instance of 'BehaviorSubject<int?>'",
          'isReplayValueStream: true',
          'has buildWhen',
          'has builder',
          'has child',
        ],
      );
    });
  });
}
