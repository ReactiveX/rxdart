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

## ValueStreamBuilder

`ValueStreamBuilder` is a widget similar to `StreamBuilder`, but works with `ValueStream` and simplifies the process of rebuilding widgets in response to stream updates. It provides a more streamlined API and performance improvements for working with streams that always have a value and do not emit errors.

### Features
- Works with `ValueStream` instead of `Stream`.
- Automatically rebuilds the widget when the stream emits new data.
- Supports optional `buildWhen` callback for more granular control over rebuild behavior.

### Usage

#### Basic Example

```dart
final valueStream = BehaviorSubject<int>.seeded(0);

ValueStreamBuilder<int>(
  stream: valueStream,
  builder: (context, data) {
    // return widget here based on data
    return Text('Current value: $data');
  },
);
```

#### Example with `buildWhen`

You can provide an optional `buildWhen` callback to control when the widget should be rebuilt based on changes to the data.

```dart
ValueStreamBuilder<int>(
  stream: valueStream,
  buildWhen: (previous, current) {
    // Only rebuild if the current value is different from the previous value
    return previous != current;
  },
  builder: (context, data) {
    return Text('Current value: $data');
  },
);
```

### Parameters

- **`stream`**: The `ValueStream` to listen to. The stream must have a value at all times and must not emit errors.
- **`builder`**: A callback that returns the widget to display based on the stream data.
- **`buildWhen`**: An optional callback that determines whether to rebuild the widget based on the previous and current data. Defaults to `true` (always rebuilds).

### Error Handling

`ValueStreamBuilder` requires the stream to always have a value and never emit errors. If an error occurs in the stream, it will be displayed using the `ErrorWidget`.

If the stream has no value when the builder is first called, a `ValueStreamHasNoValueError` will be thrown. You can handle this by ensuring that the stream is seeded with an initial value or by checking if the stream has a value before using `ValueStreamBuilder`.

