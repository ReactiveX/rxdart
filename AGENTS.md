# AGENTS.md

## Project Overview

RxDart is a ReactiveX implementation for Dart that **extends native Dart Streams** (not replacing them). Monorepo managed by [Melos](https://melos.invertase.dev/) with two published packages and examples.

## Architecture

- **`packages/rxdart`** — Core library. Zero runtime dependencies. Three pillars:
  - **Stream classes** (`lib/src/streams/`) — Extend `StreamView<R>`, wrap a `StreamController`. E.g., `CombineLatestStream`, `MergeStream`.
  - **Transformers** (`lib/src/transformers/`) — Implement `StreamTransformer`, exposed as `extension` methods on `Stream`. Use `ForwardingSink`/`forwardStream` pattern from `lib/src/utils/`.
  - **Subjects** (`lib/src/subjects/`) — Extend abstract `Subject<T>` (which extends `StreamView<T>` implements `StreamController<T>`). Three types: `BehaviorSubject`, `PublishSubject`, `ReplaySubject`.
- **`Rx` class** (`lib/src/rx.dart`) — Static factory facade for all stream constructors (e.g., `Rx.merge(...)`, `Rx.combineLatest(...)`).
- **`ValueStream<T>`** (`lib/src/streams/value_stream.dart`) — Key abstraction providing synchronous access to last emitted value. Used by `BehaviorSubject` and `rxdart_flutter` widgets.
- **`packages/rxdart_flutter`** — Flutter widgets (`ValueStreamBuilder`, `ValueStreamListener`, `ValueStreamConsumer`) that consume `ValueStream`s. Depends on `rxdart`.
- **`examples/`** — Fibonacci (CLI), Flutter GitHub search, and web examples. Not published (private packages).

## Key Commands

```bash
# Bootstrap all packages (install deps, link local packages)
melos bootstrap

# Run all rxdart tests (single entry point — see below)
melos run test-rxdart

# Run rxdart_flutter tests
melos run test-rxdart-flutter

# Analyze (public packages only)
melos run analyze-no-private

# Format check
melos run format-no-private

# Code generation (packages using build_runner)
melos run generate
```

## Testing

- **All rxdart tests** are aggregated in `packages/rxdart/test/rxdart_test.dart` — it imports every individual test file and calls each `main()`. When adding a new test, you must import it here and add the `main()` call.
- Individual test files live in `test/streams/`, `test/subject/`, `test/transformers/`, `test/utils/`, mirroring `lib/src/`.
- Tests use `package:test` with stream matchers (`emitsInOrder`, `emitsError`, `emitsDone`).
- `rxdart_flutter` tests are in `packages/rxdart_flutter/test/src/` using `flutter_test`.

## Adding New Streams

1. Create class extending `Stream` in `lib/src/streams/`.
2. Export from `lib/streams.dart`.
3. Add a static factory to the `Rx` class in `lib/src/rx.dart`.
4. Add test in `test/streams/` and register in `test/rxdart_test.dart`.
5. Enforce single-subscription contract if not broadcast; ensure stream closes properly.

## Adding New Operators (Transformers)

1. Create a `StreamTransformer` class in `lib/src/transformers/` using `ForwardingSink` + `forwardStream()`.
2. Add an `extension` method on `Stream<T>` in the same file.
3. Export from `lib/transformers.dart`.
4. Add test in `test/transformers/` and register in `test/rxdart_test.dart`.

## Code Conventions

- **`public_member_api_docs`** lint is enforced — every public member needs doc comments with `///`.
- Strict analysis: `strict-casts`, `strict-raw-types`, `strict-inference` are all enabled.
- Use single quotes for strings (`prefer_single_quotes`).
- Format with `dart format`.
- Internal utilities live in `lib/src/utils/` (not exported publicly). Key ones: `ForwardingSink`, `ForwardingStream`, `CompositeSubscription`, `ErrorAndStackTrace`.
- Barrel exports: `rxdart.dart` re-exports `streams.dart`, `subjects.dart`, `transformers.dart`, `utils.dart`. Keep these in sync when adding new files.

