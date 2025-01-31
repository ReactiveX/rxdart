import 'package:flutter/material.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatefulWidget {
  const CounterApp({
    Key? key,
  }) : super(key: key);

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final BehaviorSubject<int> valueStream = BehaviorSubject.seeded(0);

  @override
  void dispose() {
    valueStream.close();
    super.dispose();
  }

  void _valueStreamListenerListener(
      BuildContext context, int previous, int current) {
    if (current % 5 == 0) {
      final String message = '''
When value is a multiple of 5.

Previous: $previous
Current: $current''';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('ValueStreamListener.listener'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _valueStreamConsumerListener(
      BuildContext context, int previous, int current) {
    if (current % 3 == 0) {
      final String message = '''
When value is a multiple of 3.

Previous: $previous
Current: $current''';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Builder(builder: (context) {
            return ValueStreamListener(
              stream: valueStream,
              listener: _valueStreamListenerListener,
              child: ListView(
                children: [
                  ValueStreamConsumer(
                    stream: valueStream,
                    listener: _valueStreamConsumerListener,
                    builder: (context, value, child) {
                      return ValueCard(
                        title: 'ValueStreamConsumer.builder for any value',
                        value: value,
                      );
                    },
                  ),
                  ValueStreamBuilder(
                    stream: valueStream,
                    buildWhen: (previous, current) => current.isEven,
                    builder: (context, value, child) {
                      return ValueCard(
                        title: 'ValueStreamBuilder.builder when value is even',
                        value: value,
                      );
                    },
                  ),
                  ValueStreamBuilder(
                    stream: valueStream,
                    buildWhen: (previous, current) => current.isOdd,
                    builder: (context, value, child) {
                      return ValueCard(
                        title: 'ValueStreamBuilder.builder when value is odd',
                        value: value,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              valueStream.add(valueStream.value + 1);
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

enum DataCardValueShape {
  circle,
  square,
}

class ValueCard extends StatelessWidget {
  const ValueCard({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final int value;

  DataCardValueShape get _valueShape {
    if (value.isOdd) {
      return DataCardValueShape.circle;
    }
    return DataCardValueShape.square;
  }

  Color get _color {
    return switch (_valueShape) {
      DataCardValueShape.circle => Colors.green.shade700,
      DataCardValueShape.square => Colors.blue.shade700,
    };
  }

  double get _size {
    return switch (_valueShape) {
      DataCardValueShape.circle => 75,
      DataCardValueShape.square => 150,
    };
  }

  double get _borderRadius {
    return switch (_valueShape) {
      DataCardValueShape.circle => _size / 2,
      DataCardValueShape.square => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: Durations.medium1,
              height: _size,
              width: _size,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(_borderRadius),
              ),
              child: FittedBox(
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
