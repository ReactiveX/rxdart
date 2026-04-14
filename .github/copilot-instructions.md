# Copilot Instructions

For full project architecture, commands, and conventions, see [AGENTS.md](../AGENTS.md).

## Review Guidelines

- **Public API docs**: Every public member must have `///` doc comments (`public_member_api_docs` lint).
- **Strict analysis**: `strict-casts`, `strict-raw-types`, `strict-inference` are all enabled.
- **Formatting**: Single quotes (`prefer_single_quotes`), `dart format`.
- **Streams**: Stream classes extend `Stream`; transformers use `ForwardingSink` + `forwardStream()` pattern.
- **Subjects**: Extend abstract `Subject<T>`; three types: `BehaviorSubject`, `PublishSubject`, `ReplaySubject`.
- **Tests**: All `rxdart` tests must be registered in `test/rxdart_test.dart`. Use `emitsInOrder`, `emitsError`, `emitsDone` matchers.
- **Barrel exports**: Keep `rxdart.dart`, `streams.dart`, `subjects.dart`, `transformers.dart`, `utils.dart` in sync when adding new files.
- **rxdart_flutter**: Widgets consume `ValueStream`. Respect `isReplayValueStream` for correct subscription handling (skip/no-skip on first listen).

