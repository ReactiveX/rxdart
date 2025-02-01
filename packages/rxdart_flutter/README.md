# RxDart Flutter

<p align="right">
<a href="https://flutter.dev/docs/development/packages-and-plugins/favorites"><img src="https://docs.flutter.dev/assets/images/docs/development/packages-and-plugins/FlutterFavoriteLogo.png" width="100" alt="build"></a>
</p>

<p align="center">
<img src="https://github.com/ReactiveX/rxdart/blob/master/packages/rxdart/screenshots/logo.png?raw=true" height="200" alt="RxDart" />
</p>

[![Build Status](https://github.com/ReactiveX/rxdart/workflows/Dart%20CI/badge.svg)](https://github.com/ReactiveX/rxdart/actions)
[![codecov](https://codecov.io/gh/ReactiveX/rxdart/branch/master/graph/badge.svg)](https://codecov.io/gh/ReactiveX/rxdart)
[![Pub](https://img.shields.io/pub/v/rxdart_flutter.svg)](https://pub.dartlang.org/packages/rxdart_flutter)
[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/rxdart_flutter?include_prereleases&color=%23A0147B)](https://pub.dartlang.org/packages/rxdart_flutter)
[![Gitter](https://img.shields.io/gitter/room/ReactiveX/rxdart.svg)](https://gitter.im/ReactiveX/rxdart)
[![Flutter website](https://img.shields.io/badge/flutter-website-deepskyblue.svg)](https://docs.flutter.dev/data-and-backend/state-mgmt/options#bloc--rx)
[![Build Flutter example](https://github.com/ReactiveX/rxdart/actions/workflows/flutter-example.yml/badge.svg)](https://github.com/ReactiveX/rxdart/actions/workflows/flutter-example.yml)
[![License](https://img.shields.io/github/license/ReactiveX/rxdart)](https://www.apache.org/licenses/LICENSE-2.0)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FReactiveX%2Frxdart&count_bg=%23D71092&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

`rxdart_flutter` is a Flutter package that provides a set of widgets for working with `rxdart`.

These widgets are specifically designed to work with `ValueStream`s, making it easier to build reactive UIs in Flutter.

## Overview

This package provides three main widgets:
- `ValueStreamBuilder`: A widget that rebuilds UI based on `ValueStream` updates
- `ValueStreamListener`: A widget that performs side effects when `ValueStream` values change
- `ValueStreamConsumer`: A widget combining both builder and listener capabilities for `ValueStream`s

All widgets require a `ValueStream` that always has a value and never emits errors. If these conditions are not met, appropriate error widgets will be displayed.

## ValueStreamBuilder

`ValueStreamBuilder` is a widget that builds itself based on the latest value emitted by a `ValueStream`. It's similar to Flutter's `StreamBuilder` but specifically optimized for `ValueStream`s.

### Features

- Always has access to the current value (no `AsyncSnapshot` needed)
- Optional `buildWhen` condition for controlling rebuilds
- Proper error handling for streams without values or with errors
- Efficient rebuilding only when necessary

### Example

```dart
final counterStream = BehaviorSubject<int>.seeded(0); // Initial value required

ValueStreamBuilder<int>(
  stream: counterStream,
  buildWhen: (previous, current) => current != previous, // Optional rebuild condition
  builder: (context, value, child) {
    return Column(
      children: [
        Text(
          'Counter: $value',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (child != null) child, // Use the stable child widget if provided
      ],
    );
  },
  child: const Text('This widget remains stable'), // Optional stable child widget
)
```

## ValueStreamListener

`ValueStreamListener` is a widget that executes callbacks in response to stream value changes. It's perfect for handling side effects like showing snackbars, dialogs, or navigation.

### Features

- Access to both previous and current values in the listener
- No rebuilds on value changes (unlike ValueStreamBuilder)
- Child widget is preserved across stream updates
- Guaranteed to only call listener once per value change
- Optional `child` for stable widgets that remain unchanged across stream updates

### Example

```dart
final authStream = BehaviorSubject<AuthState>.seeded(AuthState.initial);

ValueStreamListener<AuthState>(
  stream: authStream,
  listener: (context, previous, current) {
    if (previous.isLoggedOut && current.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (previous.isLoggedIn && current.isLoggedOut) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  },
  child: MyApp(), // Child widget remains stable
)
```

## ValueStreamConsumer

`ValueStreamConsumer` combines the functionality of both `ValueStreamBuilder` and `ValueStreamListener`. Use it when you need to both rebuild the UI and perform side effects in response to stream changes.

### Features

- Combined builder and listener functionality
- Optional `buildWhen` condition for controlling rebuilds
- Access to previous and current values in listener
- Efficient handling of both UI updates and side effects
- Optional `child` for stable widgets that remain unchanged across stream updates

### Example

```dart
final cartStream = BehaviorSubject<Cart>.seeded(Cart.empty());

ValueStreamConsumer<Cart>(
  stream: cartStream,
  buildWhen: (previous, current) => current.itemCount != previous.itemCount,
  listener: (context, previous, current) {
    if (current.itemCount > previous.itemCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added to cart')),
      );
    }
  },
  builder: (context, cart, child) {
    return Column(
      children: [
        Text('Total items: ${cart.itemCount}'),
        Text('Total price: \$${cart.totalPrice}'),
        if (child != null) child, // Use the stable child widget if provided
      ],
    );
  },
  child: const Text('This widget remains stable'), // Optional stable child widget
)
```

## Error Handling

All widgets in this package handle two types of errors:

1. `ValueStreamHasNoValueError`: Thrown when the stream doesn't have an initial value
2. `UnhandledStreamError`: Thrown when the stream emits an error

To avoid these errors:
- Always use `BehaviorSubject` or another `ValueStream` with an initial value
- Handle stream errors before they reach these widgets
- Consider using `stream.handleError()` to transform errors if needed

Example of proper stream initialization:
```dart
// Good - stream has initial value
final goodStream = BehaviorSubject<int>.seeded(0);

// Bad - stream has no initial value
final badStream = BehaviorSubject<int>(); // Will throw ValueStreamHasNoValueError

// Bad - stream with error
final errorStream = BehaviorSubject<int>.seeded(0)..addError(Exception()); // Will throw UnhandledStreamError
```
